#include "includes.inc"
params ["_display", "_action"];
if (isNull _display) exitWith {};

disableSerialization;

private _playerUid = getPlayerUID player;
private _adminIds = getArray (missionConfigFile >> "adminIDs");
private _isAdmin = _playerUid in _adminIds;
private _isModerator = _isAdmin || _playerUid in getArray (missionConfigFile >> "moderatorIDs");
private _isModAction = _action != "report";
private _isModMenu = _display getVariable ["REP_isModerator", false];

if (_isModAction && { !_isModerator || !_isModMenu }) exitWith {};
if (_action in ["deputize", "downloadScriptLog"] && !_isAdmin) exitWith {};

if (_action == "clearTimeout") exitWith {
    private _timeoutControl = _display displayCtrl REP_TIMEOUTS_IDC;
    private _index = lbCurSel _timeoutControl;
    if (_index < 0) exitWith {};

    private _uid = _timeoutControl lbData _index;
    private _punishmentMap = missionNamespace getVariable ["WL2_punishmentMap", createHashMap];
    if !(_uid in _punishmentMap) exitWith {
        [_display] call REP_fnc_refresh;
    };

    _punishmentMap deleteAt _uid;
    missionNamespace setVariable ["WL2_punishmentMap", _punishmentMap, true];

    [_display] call REP_fnc_refresh;
    systemChat format [localize "STR_WL_repClearedTimeout", _uid];
};

private _uid = _display getVariable ["REP_selectedUid", ""];
if (_uid == "") exitWith {
    systemChat localize "STR_WL_reportSelectPlayer";
};

private _selectedPlayers = (call BIS_fnc_listPlayers) select { getPlayerUID _x == _uid };
if (count _selectedPlayers == 0) exitWith {
    [_display] call REP_fnc_refresh;
    systemChat localize "STR_WL_reportDisconnected";
};

private _selectedPlayer = _selectedPlayers # 0;
private _playerName = [_selectedPlayer, true] call BIS_fnc_getName;
private _refresh = false;
private _status = "";

switch (_action) do {
    case "report": {
        private _reasonControl = _display displayCtrl REP_REASON_IDC;
        private _reason = trim ctrlText _reasonControl;

        if (_reason == "") then {
            _reason = localize "STR_WL_reportDefaultReason";
        };

        private _submitControl = _display displayCtrl REP_SUBMIT_IDC;
        _submitControl ctrlEnable false;

        [player, _uid, _reason] remoteExec ["REP_fnc_reportPlayer", 2];
        systemChat format [localize "STR_WL_reportSubmitted", _playerName, _reason];
        _display closeDisplay 0;
    };

    case "timeout": {
        private _timeoutData = [_display, true] call REP_fnc_updateTimeout;
        _timeoutData params ["_duration", "_reason"];

        private _beid = [_uid] call WL2_fnc_guidToBeid;
        private _systemTime = [systemTimeUTC] call REP_fnc_printSystemTime;

        private _receipt = [
            format ["[NAME] %1", _playerName],
            format ["[BEID] %1", _beid],
            format ["[GUID] %1", _uid],
            format ["[TIME] %1", _systemTime],
            format ["[TIMEOUT] %1 minutes", _duration],
            format ["[REASON] %1", _reason],
            "",
            ""
        ] joinString toString [10];

        private _receipts = missionProfileNamespace getVariable ["WL2_infoDisplay", ""];
        missionProfileNamespace setVariable ["WL2_infoDisplay", _receipts + _receipt];

        [player, _uid, _reason, _duration * 60] remoteExec ["WL2_fnc_punishPlayer", 2];
        _status = format [localize "STR_WL_repTimedOut", _playerName, _duration];
        _refresh = true;
    };

    case "rebalance": {
        if !(side group _selectedPlayer in [west, east]) exitWith {
            _status = localize "STR_WL_repOnlyBluforOpfor";
        };

        [player, _uid] remoteExec ["WL2_fnc_rebalance", 2];
        _status = format [localize "STR_WL_repRebalanceRequested", _playerName];
        _refresh = true;
    };

    case "gotoPlayer": {
        if (!alive _selectedPlayer || _selectedPlayer == player) exitWith {};

        private _position = _selectedPlayer modelToWorld [0, 0, 0];
        cameraOn setVehiclePosition [_position, [], 3, "NONE"];
        _status = format [localize "STR_WL_repMoved", _playerName];
    };

    case "mutePlayer": {
        private _canTalk = _selectedPlayer getVariable ["WL2_canTalk", true];

        [!_canTalk] remoteExec ["WL2_fnc_mutePlayer", _selectedPlayer];
        _selectedPlayer setVariable ["WL2_canTalk", !_canTalk, true];

        private _muteText = if (_canTalk) then { localize "STR_WL_repMuted" } else { localize "STR_WL_repUnmuted" };
        _status = format ["%1 %2.", _muteText, _playerName];
        _refresh = true;
    };

    case "seeTransfers": {
        private _transfers = _selectedPlayer getVariable ["WL2_playerTransfers", []];
        private _logText = str _transfers;
        private _logTitle = format [localize "STR_WL_repTransfersLogTitle", _playerName];

        [_display, _logText, _logTitle] call REP_fnc_showLog;
        _status = format [localize "STR_WL_repTransfers", _playerName];
    };

    case "seeAFKLog": {
        private _afkLog = _selectedPlayer getVariable ["WL2_afkLog", createHashMap];
        private _afkLogArray = _afkLog toArray false;
        _afkLogArray = [_afkLogArray, [], { _x # 0 }, "ASCEND"] call BIS_fnc_sortBy;

        private _logText = str _afkLogArray;
        private _logTitle = format [localize "STR_WL_repAfkLogTitle", _playerName];

        [_display, _logText, _logTitle] call REP_fnc_showLog;
        _status = format [localize "STR_WL_repShowingAfkLog", _playerName];
    };

    case "seeRewardLog": {
        [_uid] remoteExec ["WL2_fnc_publishRewards", 2];
        _status = format [localize "STR_WL_repRewardLog", _playerName];
    };

    case "downloadScriptLog": {
        if (_uid in _adminIds) exitWith {
            _status = localize "STR_WL_repScriptLogsUnavailable";
        };

        if (missionNamespace getVariable ["REP_scriptLogPending", false]) exitWith {
            _status = localize "STR_WL_repScriptLogPending";
        };

        missionNamespace setVariable ["REP_scriptLogPending", true];
        private _requester = player;
        _requester setVariable ["WL2_response", nil];

        [_requester, clientOwner] remoteExec ["WL2_fnc_publishSelfLog", _selectedPlayer];
        [_display] call REP_fnc_refresh;
        systemChat format [localize "STR_WL_repRequestingLog", _playerName];

        private _deadline = diag_tickTime + 15;
        waitUntil {
            uiSleep 0.1;

            !isNil { _requester getVariable "WL2_response" } || isNull _display || isNull _selectedPlayer || diag_tickTime >= _deadline;
        };

        missionNamespace setVariable ["REP_scriptLogPending", false];
        if (isNull _display) exitWith {};

        private _response = _requester getVariable ["WL2_response", []];
        _requester setVariable ["WL2_response", nil];
        [_display] call REP_fnc_refresh;

        private _selectedUid = _display getVariable ["REP_selectedUid", ""];
        if (_selectedUid != _uid) exitWith {};
        if (_response isEqualTo []) exitWith {
            _status = format [localize "STR_WL_repNoScriptLog", _playerName];
        };

        private _logText = if (_response isEqualType []) then {
            _response joinString toString [10]
        } else {
            if (_response isEqualType "") then { _response } else { str _response }
        };

        private _logTitle = format [localize "STR_WL_repScriptLogTitle", _playerName];
        [_display, _logText, _logTitle] call REP_fnc_showLog;
        _status = format [localize "STR_WL_repReceivedScriptLog", _playerName];
    };

    case "deputize": {
        missionNamespace setVariable ["WL2_tempSpectatorUID", _uid, true];
        _status = format [localize "STR_WL_repDeputized", _playerName];
        _refresh = true;
    };

    case "playTutorial": {
        [] remoteExec ["TUT_fnc_play", _selectedPlayer];
        _status = format [localize "STR_WL_repTutorialPlayback", _playerName];
    };

    case "clearReports": {
        [] remoteExec ["WL2_fnc_clearPlayerReports", _selectedPlayer];
        _status = format [localize "STR_WL_repClearedLogs", _playerName];
        _refresh = true;
    };
};

if (isNull _display) exitWith {};

if (_refresh) then {
    [_display] call REP_fnc_refresh;

    [_display] spawn {
        params ["_display"];
        disableSerialization;

        uiSleep 1;

        if (!isNull _display) then {
            [_display] call REP_fnc_refresh;
        };
    };
};

if (_status != "") then {
    systemChat _status;
};
