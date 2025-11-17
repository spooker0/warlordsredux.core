#include "includes.inc"

private _playerUid = getPlayerUID player;
private _isAdmin = _playerUid in getArray (missionConfigFile >> "adminIDs");
private _isModerator = _playerUid in getArray (missionConfigFile >> "moderatorIDs");
if !(_isAdmin || _isModerator) exitWith {};

private _display = findDisplay 5500;
if (isNull _display) then {
    _display = createDialog ["RscWLBrowserMenu", true];
};
private _texture = _display displayCtrl 5501;
_texture ctrlWebBrowserAction ["LoadFile", "src\ui\gen\mod.html"];
// _texture ctrlWebBrowserAction ["OpenDevConsole"];

_texture ctrlAddEventHandler ["JSDialog", {
    params ["_texture", "_isConfirmDialog", "_message"];
    playSoundUI ["a3\ui_f\data\sound\rsclistbox\soundselect.wss", 0.5];
    if (_message == "exit") exitWith {
        closeDialog 0;
    };

    _message = fromJSON _message;
    private _action = _message select 0;
    switch (_action) do {
        case "error": {
            private _errorMessage = _message select 1;
            systemChat format ["[MOD]: %1", _errorMessage];
            diag_log format ["[MOD] %1", _errorMessage];
        };
        case "select": {
            private _uid = _message select 1;

            private _allPlayers = call BIS_fnc_listPlayers;
            private _selectedPlayer = _allPlayers select { getPlayerUID _x == _uid };
            if (count _selectedPlayer == 0) exitWith { true };
            _selectedPlayer = _selectedPlayer select 0;

            private _playerName = [_selectedPlayer, true] call BIS_fnc_getName;
            private _systemTimeDisplay = [systemTimeUTC] call MENU_fnc_printSystemTime;

            private _playerReports = _selectedPlayer getVariable ["WL2_playerReports", createHashMap];
            private _playerReportArray = [];
            {
                private _reporter = _x;
                private _reportData = _y;

                _reportData = if (_reportData isEqualType []) then {
                    private _reportTime = _reportData select 1;
                    [_reportData select 0, [systemTimeUTC] call MENU_fnc_printSystemTime];
                } else {
                    [_reportData, "?"];
                };

                _playerReportArray pushBack [_reporter, _reportData];
            } forEach _playerReports;

            private _playerData = [_uid, _playerName, _systemTimeDisplay, _playerReportArray];
            private _playerDataJson = toJSON _playerData;
            _playerDataJson = _texture ctrlWebBrowserAction ["ToBase64", _playerDataJson];
            private _script = format [
                "updatePlayerInfo(atobr(""%1""));",
                _playerDataJson
            ];
            _texture ctrlWebBrowserAction ["ExecJS", _script];
        };
        case "timeout": {
            private _uid = _message select 1;
            private _duration = _message select 2;
            private _reason = _message select 3;
            _reason = _texture ctrlWebBrowserAction ["FromBase64", _reason];
            private _displayString = _message select 4;
            _displayString = _texture ctrlWebBrowserAction ["FromBase64", _displayString];

            private _existingInfoDisplay = profileNamespace getVariable ["WL2_infoDisplay", ""];
            private _banText = format ["%1%2", _existingInfoDisplay, _displayString];
            profileNamespace setVariable ["WL2_infoDisplay", _banText];

            _duration = _duration * 60;
            [player, _uid, _reason, _duration] remoteExec ["WL2_fnc_punishPlayer", 2];
        };
        case "addModReceipt": {
            private _receiptText = _message select 1;
            _receiptText = _texture ctrlWebBrowserAction ["FromBase64", _receiptText];

            private _existingInfoDisplay = profileNamespace getVariable ["WL2_infoDisplay", ""];
            private _banText = format ["%1%2", _existingInfoDisplay, _receiptText];
            profileNamespace setVariable ["WL2_infoDisplay", _banText];
        };
        case "rebalance": {
            private _uid = _message select 1;
            [player, _uid] remoteExec ["WL2_fnc_rebalance", 2];
        };
        case "accessVehicles": {
            private _uid = _message select 1;
            systemChat "Mod vehicle access granted.";
            uiNamespace setVariable ["WL2_modOverrideUid", _uid];
            0 spawn WL2_fnc_vehicleManager;
        };
        case "gotoPlayer": {
            private _uid = _message select 1;
            private _selectedPlayer = [_uid] call BIS_fnc_getUnitByUID;
            if (isNull _selectedPlayer) exitWith { true };
            cameraOn setVehiclePosition [_selectedPlayer modelToWorld [0, 0, 0], [], 3, "NONE"];
        };
        case "mutePlayer": {
            private _uid = _message select 1;
            private _selectedPlayer = [_uid] call BIS_fnc_getUnitByUID;
            if (isNull _selectedPlayer) exitWith { true };
            private _canTalk = _selectedPlayer getVariable ["WL2_canTalk", true];
            [!_canTalk] remoteExec ["WL2_fnc_mutePlayer", _selectedPlayer];
            _selectedPlayer setVariable ["WL2_canTalk", !_canTalk, true];
        };
        case "seeTransfers": {
            private _uid = _message select 1;
            private _selectedPlayer = [_uid] call BIS_fnc_getUnitByUID;
            if (isNull _selectedPlayer) exitWith { true };
            private _transferHistory = _selectedPlayer getVariable ["WL2_playerTransfers", []];
            [_texture, str _transferHistory] spawn MENU_fnc_copyChat;
        };
        case "seeAFKLog": {
            private _uid = _message select 1;
            private _selectedPlayer = [_uid] call BIS_fnc_getUnitByUID;
            if (isNull _selectedPlayer) exitWith { true };
            private _afkLog = _selectedPlayer getVariable ["WL2_afkLog", createHashMap];
            private _afkLogArray = _afkLog toArray false;
            _afkLogArray = [_afkLogArray, [], { _x # 0 }, "ASCEND"] call BIS_fnc_sortBy;
            [_texture, str _afkLogArray] spawn MENU_fnc_copyChat;
        };
        case "deputize": {
            private _uid = _message select 1;
            missionNamespace setVariable ["WL2_tempSpectatorUID", _uid, true];
        };
        case "clearReports": {
            private _uid = _message select 1;
            private _selectedPlayer = [_uid] call BIS_fnc_getUnitByUID;
            if (isNull _selectedPlayer) exitWith { true };
            [] remoteExec ["WL2_fnc_clearPlayerReports", _selectedPlayer];
        };
        case "modReceipts": {
            profileNamespace setVariable ["WL2_infoDisplay", ""];
        };
        case "clearTimeout": {
            private _uid = _message select 1;

            private _punishmentMap = missionNamespace getVariable ["WL2_punishmentMap", createHashMap];
            _punishmentMap deleteAt _uid;
            missionNamespace setVariable ["WL2_punishmentMap", _punishmentMap, true];
        };
    };

    [_texture] spawn {
        _this call MENU_fnc_sendModData;
        uiSleep 1;
        _this call MENU_fnc_sendModData;
    };

    true;
}];

_texture ctrlAddEventHandler ["PageLoaded", {
    _this spawn {
        params ["_texture"];
        while { !isNull _texture } do {
            [_texture] call MENU_fnc_sendModData;
            uiSleep 5;
        };
    };
}];