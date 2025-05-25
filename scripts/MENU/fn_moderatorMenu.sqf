/*
    Adapted from old report menu. Original Author: f1x1t
*/

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
private _playerAliases = profileNamespace getVariable ["WL2_playerAliases", createHashMap];
{
    private _playerName = [_x] call BIS_fnc_getName;
    private _lbIndex = _playerList lbAdd _playerName;
    _playerList lbSetData [_lbIndex, getPlayerUID _x];

    if (_elevatedPrivilege) then {
        private _playerUid = getPlayerUID _x;
        private _playerNames = _playerAliases getOrDefault [_playerUid, []];
        _playerNames = _playerNames select {
            _x != _playerName
        };
        if (count _playerNames > 0) then {
            private _playerNameDisplay = format["Aliases:%1%2", endl, _playerNames joinString endl];
            _playerList lbSetTooltip [_lbIndex, _playerNameDisplay];
        };
    };
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
private _chatHistoryList = _display displayCtrl MODR_CHAT_HISTORY;

private _chatHistoryCopy5 = _display displayCtrl MODR_CHAT_HISTORY_COPY_5;
private _chatHistoryCopy20 = _display displayCtrl MODR_CHAT_HISTORY_COPY_20;
private _chatHistoryCopyAll = _display displayCtrl MODR_CHAT_HISTORY_COPY_ALL;

private _reportTable = _display displayCtrl MODR_REPORT_TABLE;
private _clearReports = _display displayCtrl MODR_CLEAR_REPORTS;
private _clearTimeout = _display displayCtrl MODR_CLEAR_TIMEOUT;
private _rebalance = _display displayCtrl MODR_REBALANCE;

_infoDisplay ctrlShow false;
_timeoutReasonLabel ctrlShow false;
_timeoutReasonEdit ctrlShow false;
_timeoutTime ctrlShow false;
_timeoutButton ctrlShow false;
_chatHistoryList ctrlShow false;

_chatHistoryCopy5 ctrlShow false;
_chatHistoryCopy20 ctrlShow false;
_chatHistoryCopyAll ctrlShow false;

_reportTable ctrlShow false;
_clearReports ctrlShow false;
_rebalance ctrlShow false;

_clearTimeout ctrlShow false;

if (_elevatedPrivilege) then {
    if (!_isAdmin) then {
        _timeoutTime sliderSetRange [1, 30];
    };

    for "_i" from 0 to (lbSize _playerList - 1) do {
        private _uid = _playerList lbData _i;
        private _selectedPlayer = [_uid] call BIS_fnc_getUnitByUID;
        if (isNull _selectedPlayer) exitWith {};

        private _playerReports = _selectedPlayer getVariable ["WL2_playerReports", createHashMap];
        _playerList lbSetTextRight [_i, str count _playerReports];
    };

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

    _chatHistoryList ctrlShow true;
    [_display] spawn MENU_fnc_refreshChat;

    _chatHistoryCopy5 ctrlShow true;
    _chatHistoryCopy5 ctrlAddEventHandler ["ButtonClick", {
        params ["_control"];
        [_control, 5] spawn MENU_fnc_copyChat;
    }];

    _chatHistoryCopy20 ctrlShow true;
    _chatHistoryCopy20 ctrlAddEventHandler ["ButtonClick", {
        params ["_control"];
        [_control, 20] spawn MENU_fnc_copyChat;
    }];

    _chatHistoryCopyAll ctrlShow true;
    _chatHistoryCopyAll ctrlAddEventHandler ["ButtonClick", {
        params ["_control"];
        [_control, -1] spawn MENU_fnc_copyChat;
    }];

    _clearReports ctrlAddEventHandler ["ButtonClick", {
        params ["_control"];
        private _display = ctrlParent _control;

        private _playerList = _display displayCtrl MODR_PLAYER_LIST;
        private _selectedIndex = lbCurSel _playerList;
        private _selectedUid = _playerList lbData _selectedIndex;

        private _selectedPlayer = [_selectedUid] call BIS_fnc_getUnitByUID;

        if (isNull _selectedPlayer) exitWith {};
        [] remoteExec ["WL2_fnc_clearPlayerReports", _selectedPlayer];
    }];
    _rebalance ctrlAddEventHandler ["ButtonClick", {
        params ["_control"];
        private _display = ctrlParent _control;

        private _playerList = _display displayCtrl MODR_PLAYER_LIST;
        private _selectedIndex = lbCurSel _playerList;
        private _selectedUid = _playerList lbData _selectedIndex;

        [player, _selectedUid] remoteExec ["WL2_fnc_rebalance", 2];
    }];

    _clearTimeout ctrlAddEventHandler ["ButtonClick", {
        [player] remoteExec ["WL2_fnc_clearAllTimeouts", 2];
    }];
    _clearTimeout ctrlShow true;
} else {
    _playerList ctrlSetPositionH 0.9;
    _playerList ctrlCommit 0;

    _timeoutButton ctrlAddEventHandler ["ButtonClick", {
        params ["_control"];
        private _display = ctrlParent _control;

        private _playerList = _display displayCtrl MODR_PLAYER_LIST;
        private _selectedIndex = lbCurSel _playerList;
        private _selectedUid = _playerList lbData _selectedIndex;

        private _reasonEdit = _display displayCtrl MODR_TIMEOUT_REASON;
        private _reasonText = ctrlText _reasonEdit;

        [player, _selectedUid, _reasonText] remoteExec ["MENU_fnc_reportPlayer", 2];

        playSoundUI ["AddItemOk"];
        private _selectedPlayer = [_selectedUid] call BIS_fnc_getUnitByUID;
        private _playerName = [_selectedPlayer, true] call BIS_fnc_getName;
        systemChat format["Reported %1 for %2", _playerName, _reasonText];
    }];
};

_playerList ctrlAddEventHandler ["LBSelChanged", {
    params ["_control", "_selectedIndex"];
    private _selectedUid = _control lbData _selectedIndex;
    private _selectedPlayer = [_selectedUid] call BIS_fnc_getUnitByUID;
    private _playerName = [_selectedPlayer, true] call BIS_fnc_getName;

    uiNamespace setVariable ["MODR_selectedPlayer", _selectedPlayer];
    uiNamespace setVariable ["MODR_passedName", _playerName];
    uiNamespace setVariable ["MODR_returnedBeId", ""];

    diag_log "serverCommand #beclient players";
    serverCommand "#beclient players";

    // Mock reply for offline test
    // 0 spawn {
    //     sleep 3;
    //     uiNamespace setVariable ["MODR_returnedBeId", "8ea8a9d51cc24705b60dcab0152b0905"];
    // };

    [_selectedPlayer] spawn MENU_fnc_moderatorLoaded;
}];