#include "constants.inc"

params ["_elevatedPrivilege"];

private _playerUid = getPlayerUID player;
private _isAdmin = _playerUid in getArray (missionConfigFile >> "adminIDs");
private _isModerator = _playerUid in getArray (missionConfigFile >> "moderatorIDs");
if (_elevatedPrivilege && !(_isAdmin || _isModerator)) exitWith {};

private _display = findDisplay MODR_DISPLAY;
if (isNull _display) then {
    _display = createDialog ["MODR_Menu", true];
};

disableSerialization;

private _closeButton = _display displayCtrl MODR_CLOSE_BUTTON;
_closeButton ctrlAddEventHandler ["ButtonClick", {
    closeDialog 0;
}];

private _playerList = _display displayCtrl MODR_PLAYER_LIST;
private _allPlayers = call BIS_fnc_listPlayers;
{
    private _lbIndex = _playerList lbAdd ([_x] call BIS_fnc_getName);
    _playerList lbSetData [_lbIndex, getPlayerUID _x];
} forEach _allPlayers;

_display setVariable ["MODR_elevatedPrivilege", _elevatedPrivilege];

private _titleBar = _display displayCtrl MODR_TITLE_BAR;
if (_elevatedPrivilege) then {
    _titleBar ctrlSetText "Moderator Menu";
} else {
    _titleBar ctrlSetText "Report Menu";
};

private _infoDisplay = _display displayCtrl MODR_INFO_DISPLAY;
private _timeoutReasonLabel = _display displayCtrl MODR_TIMEOUT_REASON_LABEL;
private _timeoutReasonEdit = _display displayCtrl MODR_TIMEOUT_REASON;
private _timeoutTime = _display displayCtrl MODR_TIMEOUT_TIME;
private _timeoutButton = _display displayCtrl MODR_TIMEOUT_BUTTON;

_infoDisplay ctrlShow false;
_timeoutReasonLabel ctrlShow false;
_timeoutReasonEdit ctrlShow false;
_timeoutTime ctrlShow false;
_timeoutButton ctrlShow false;

if (_elevatedPrivilege) then {
    _timeoutTime ctrlAddEventHandler ["SliderPosChanged", {
        params ["_control", "_newPosition"];
        private _display = ctrlParent _control;

        private _playerList = _display displayCtrl MODR_PLAYER_LIST;
        private _selectedIndex = lbCurSel _playerList;
        private _selectedUid = _playerList lbData _selectedIndex;
        private _selectedPlayer = [_selectedUid] call BIS_fnc_getUnitByUID;
        private _playerName = [_selectedPlayer, true] call BIS_fnc_getName;

        private _timeoutButton = _display displayCtrl MODR_TIMEOUT_BUTTON;
        _timeoutButton ctrlSetText format["Timeout %1 for %2 minutes", _playerName, _newPosition];
    }];

    _timeoutButton ctrlAddEventHandler ["ButtonClick", {
        params ["_control"];
        private _display = ctrlParent _control;

        private _playerList = _display displayCtrl MODR_PLAYER_LIST;
        private _selectedIndex = lbCurSel _playerList;
        private _selectedUid = _playerList lbData _selectedIndex;

        private _timeoutTime = _display displayCtrl MODR_TIMEOUT_TIME;
        private _timeoutValue = sliderPosition _timeoutTime;
        _timeoutValue = _timeoutValue * 60;

        private _reasonEdit = _display displayCtrl MODR_TIMEOUT_REASON;
        private _reasonText = ctrlText _reasonEdit;

        [player, _selectedUid, _reasonText, _timeoutValue] remoteExec ["WL2_fnc_punishPlayer", 2];
    }];
};

_playerList ctrlAddEventHandler ["LBSelChanged", {
    params ["_control", "_selectedIndex"];
    private _selectedUid = _control lbData _selectedIndex;
    private _selectedPlayer = [_selectedUid] call BIS_fnc_getUnitByUID;
    private _playerName = [_selectedPlayer, true] call BIS_fnc_getName;

    uiNamespace setVariable ["MODR_passedName", _playerName];
    uiNamespace setVariable ["MODR_returnedBeId", ""];

    diag_log "serverCommand #beclient players";
    serverCommand "#beclient players";

    // Mock reply for offline test
    // 0 spawn {
    //     sleep 3;
    //     uiNamespace setVariable ["MODR_returnedBeId", "8ea8a9d51cc24705b60dcab0152b0905"];
    // };

    [_selectedPlayer] spawn {
        params ["_selectedPlayer"];
        private _display = findDisplay MODR_DISPLAY;
        if (isNull _display) exitWith {};

        private _infoDisplay = _display displayCtrl MODR_INFO_DISPLAY;
        _infoDisplay ctrlShow true;

        private _playerName = [_selectedPlayer, true] call BIS_fnc_getName;
        private _playerGuid = getPlayerUID _selectedPlayer;

        private _timeoutTime = _display displayCtrl MODR_TIMEOUT_TIME;
        private _timeoutButton = _display displayCtrl MODR_TIMEOUT_BUTTON;
        _timeoutButton ctrlSetText format["Timeout %1 for %2 minutes", _playerName, sliderPosition _timeoutTime];

        private _systemTimeUtc = systemTimeUTC apply {
            if (_x < 10) then {
                format ["0%1", _x];
            } else {
                str _x;
            };
        };
        _systemTimeUtc params ["_year", "_month", "_day", "_hour", "_minute", "_second"];

        private _gmtTimeString = format["%1/%2/%3 %4:%5:%6", _year, _month, _day, _hour, _minute, _second];
        private _fullDisplayString = format["[Name] %1%5[BEID] %2%5[GUID] %3%5[UTC] %4", _playerName, "Loading...", _playerGuid, _gmtTimeString, endl];
        _infoDisplay ctrlSetText _fullDisplayString;

        private _beIdReply = "";
        private _startTime = serverTime;
        waitUntil {
            sleep 0.1;
            _beIdReply = uiNamespace getVariable ["MODR_returnedBeId", ""];
            _beIdReply != "" || serverTime - _startTime > 10;
        };
        if (_beIdReply == "") then {
            _beIdReply = "Failed to load Battleye info...";
        };

        _fullDisplayString = format["[Name] %1%5[BEID] %2%5[GUID] %3%5[UTC] %4", _playerName, _beIdReply, _playerGuid, _gmtTimeString, endl];
        _infoDisplay ctrlSetText _fullDisplayString;

        private _elevated = _display getVariable ["MODR_elevatedPrivilege", false];

        private _timeoutReasonLabel = _display displayCtrl MODR_TIMEOUT_REASON_LABEL;
        private _timeoutReasonEdit = _display displayCtrl MODR_TIMEOUT_REASON;

        if (_elevated) then {
            _timeoutReasonLabel ctrlShow true;
            _timeoutReasonEdit ctrlShow true;
            _timeoutTime ctrlShow true;
            _timeoutButton ctrlShow true;
        } else {
            _timeoutReasonLabel ctrlShow false;
            _timeoutReasonEdit ctrlShow false;
            _timeoutTime ctrlShow false;
            _timeoutButton ctrlShow false;
        };
    };
}];