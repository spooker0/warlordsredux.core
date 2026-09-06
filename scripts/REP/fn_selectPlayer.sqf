#include "includes.inc"
params ["_display", "_uid"];
if (isNull _display) exitWith {};

private _moderate = _display getVariable ["REP_isModerator", false];
private _selectedPlayer = if (_uid == "") then {
    objNull
} else {
    [_uid] call BIS_fnc_getUnitByUID
};

if (isNull _selectedPlayer) then {
    _uid = "";
};

private _previousUid = _display getVariable ["REP_selectedUid", ""];
_display setVariable ["REP_selectedUid", _uid];

private _hasPlayer = _uid != "";
private _isAdmin = _display getVariable ["REP_isAdmin", false];

private _detailsGroup = _display displayCtrl REP_DETAILS_IDC;
private _playerNameControl = _display displayCtrl REP_PLAYER_NAME_IDC;
private _infoControl = _display displayCtrl REP_INFO_IDC;
private _copyInfoButton = _display displayCtrl REP_COPY_INFO_IDC;
private _reasonControl = _display displayCtrl REP_REASON_IDC;
private _submitButton = _display displayCtrl REP_SUBMIT_IDC;
private _reportsControl = _display displayCtrl REP_REPORTS_IDC;
private _copyLabel = localize "STR_WL_copy";

_detailsGroup ctrlShow _hasPlayer;
_reasonControl ctrlEnable _hasPlayer;
_submitButton ctrlEnable _hasPlayer;

{
    _x params ["_button", "_playerUid"];
    private _selected = _playerUid == _uid;

    private _backgroundColor = if (_selected) then { [REP_RGBA_LIGHT] } else { [REP_RGBA_DARK] };
    private _nameColor = if (_selected) then { "#efbf05" } else { "#ffffff" };
    private _nameText = _button getVariable ["REP_playerName", ""];
    private _buttonText = format ["<t align='left' color='%1'>%2</t>", _nameColor, _nameText];

    if (_moderate) then {
        private _reportCount = _button getVariable ["REP_reportCount", 0];
        _buttonText = _buttonText + format ["<t align='right' color='#ff5555'>%1</t>", _reportCount];
    };

    private _structuredText = parseText _buttonText;

    _button ctrlSetBackgroundColor _backgroundColor;
    _button ctrlSetStructuredText _structuredText;
} forEach (_display getVariable ["REP_playerButtons", []]);

if (_moderate) then {
    {
        private _control = _display displayCtrl _x;
        _control ctrlEnable _hasPlayer;
    } forEach [
        REP_DURATION_IDC,
        REP_SLIDER_IDC,
        REP_REBALANCE_IDC,
        REP_GOTO_IDC,
        REP_MUTE_IDC,
        REP_TRANSFERS_IDC,
        REP_AFK_IDC,
        REP_REWARDS_IDC,
        REP_CLEAR_REPORTS_IDC
    ];

    {
        private _control = _display displayCtrl _x;
        _control ctrlEnable (_hasPlayer && _isAdmin);
    } forEach [REP_SCRIPTS_IDC, REP_DEPUTIZE_IDC];

    if (_previousUid != _uid || !_hasPlayer) then {
        private _logGroup = _display displayCtrl REP_LOG_GROUP_IDC;
        private _logPosition = ctrlPosition _logGroup;
        _logGroup ctrlShow false;
        _logPosition set [3, 0];
        _logGroup ctrlSetPosition _logPosition;
        _logGroup ctrlCommit 0;
    };
};

if (!_hasPlayer) exitWith {
    _display setVariable ["REP_playerInfo", ""];
    _display setVariable ["REP_selectedName", ""];
    _display setVariable ["REP_identity", []];

    _playerNameControl ctrlSetText "";
    _infoControl ctrlSetText "";
    _reportsControl ctrlSetText "";

    [_copyInfoButton, "", _copyLabel] call REP_fnc_setCopyButton;
};

private _playerName = [_selectedPlayer, true] call BIS_fnc_getName;
private _displayUid = _uid;
if (!_moderate) then {
    private _hiddenIdentity = _selectedPlayer getVariable ["WL2_hideIdentity", ""];
    if (_hiddenIdentity != "") then {
        _displayUid = _hiddenIdentity;
    };
};

private _identity = [_uid, _displayUid, _playerName];
if (_identity isNotEqualTo (_display getVariable ["REP_identity", []])) then {
    private _beids = _display getVariable ["REP_beids", createHashMap];
    private _beid = _beids getOrDefault [_displayUid, ""];

    if (_beid == "") then {
        _beid = [_displayUid] call WL2_fnc_guidToBeid;
        _beids set [_displayUid, _beid];
        _display setVariable ["REP_beids", _beids];
    };

    private _systemTime = [systemTimeUTC] call REP_fnc_printSystemTime;
    private _info = [
        format ["[NAME] %1", _playerName],
        format ["[BEID] %1", _beid],
        format ["[GUID] %1", _displayUid],
        format ["[TIME] %1", _systemTime]
    ] joinString toString [10];

    _display setVariable ["REP_identity", _identity];
    _display setVariable ["REP_playerInfo", _info];
    _display setVariable ["REP_selectedName", _playerName];

    _playerNameControl ctrlSetText _playerName;
    _infoControl ctrlSetText _info;
};

private _playerInfo = _display getVariable ["REP_playerInfo", ""];
[_copyInfoButton, _playerInfo, _copyLabel] call REP_fnc_setCopyButton;

if (_previousUid != _uid) then {
    private _defaultReason = if (_moderate) then {
        REP_DEFAULT_REASON
    } else {
        localize "STR_WL_reportDefaultReason"
    };

    _reasonControl ctrlSetText _defaultReason;
};

if (_moderate) then {
    private _scriptsButton = _display displayCtrl REP_SCRIPTS_IDC;
    private _rebalanceButton = _display displayCtrl REP_REBALANCE_IDC;
    private _gotoButton = _display displayCtrl REP_GOTO_IDC;
    private _muteButton = _display displayCtrl REP_MUTE_IDC;

    _scriptsButton ctrlEnable (
        _isAdmin &&
        !(_uid in getArray (missionConfigFile >> "adminIDs")) &&
        !(missionNamespace getVariable ["REP_scriptLogPending", false])
    );

    _rebalanceButton ctrlEnable (side group _selectedPlayer in [west, east]);
    _gotoButton ctrlEnable (alive _selectedPlayer && _selectedPlayer != player);

    private _reports = _selectedPlayer getVariable ["WL2_playerReports", createHashMap];
    private _reportLines = [];
    {
        private _reason = _y;
        private _reportTime = "?";

        if (_reason isEqualType []) then {
            _reportTime = [_reason # 1] call REP_fnc_printSystemTime;
            _reason = _reason # 0;
        };

        _reportLines pushBack format ["By: %1 (%2)", _x, _reportTime];
        _reportLines pushBack _reason;
        _reportLines pushBack "";
    } forEach _reports;

    private _reportText = if (count _reportLines == 0) then {
        "No reports."
    } else {
        _reportLines joinString toString [10]
    };

    if (ctrlText _reportsControl != _reportText) then {
        _reportsControl ctrlSetText _reportText;
    };

    private _canTalk = _selectedPlayer getVariable ["WL2_canTalk", true];
    private _muteText = if (_canTalk) then { "Mute player" } else { "Unmute player" };
    _muteButton ctrlSetText _muteText;

    [_display] call REP_fnc_updateTimeout;
};
