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

private _guidMap = uiNamespace getVariable ["WL2_guidMap", createHashMap];
private _allPlayersHaveGuid = true;
{
    private _playerName = [_x, true] call BIS_fnc_getName;
    private _guid = _guidMap getOrDefault [_playerName, ""];
    if (_guid == "") then {
        _allPlayersHaveGuid = false;
    };
} forEach allPlayers;
if (!_allPlayersHaveGuid) then {
    diag_log "serverCommand #beclient players";
    systemChat "Requesting player GUIDs from BE...";
    serverCommand "#beclient players";
};

_texture ctrlAddEventHandler ["JSDialog", {
    params ["_texture", "_isConfirmDialog", "_message"];
    playSoundUI ["a3\ui_f\data\sound\rsclistbox\soundselect.wss", 0.5];
    if (_message == "exit") exitWith {
        closeDialog 0;
    };

    _message = fromJSON _message;
    private _action = _message select 0;
    switch (_action) do {
        case "select": {
            private _uid = _message select 1;

            private _allPlayers = call BIS_fnc_listPlayers;
            private _selectedPlayer = _allPlayers select { getPlayerUID _x == _uid };
            if (count _selectedPlayer == 0) exitWith { true };
            _selectedPlayer = _selectedPlayer select 0;
                        
            private _playerName = [_selectedPlayer, true] call BIS_fnc_getName;

            private _guidMap = uiNamespace getVariable ["WL2_guidMap", createHashMap];
            private _guid = _guidMap getOrDefault [_playerName, ""];
            private _systemTimeDisplay = [systemTimeUTC] call MENU_fnc_printSystemTime;
            private _fullDisplayString = format["[NAME] %1%5[BEID] %2%5[GUID] %3%5[UTC] %4", _playerName, _guid, _uid, _systemTimeDisplay, endl];

            uiNamespace setVariable ["WL2_currentModDisplayString", _fullDisplayString];

            private _playerReports = _selectedPlayer getVariable ["WL2_playerReports", createHashMap];
            private _playerReportArray = [];
            {
                private _reporter = _x;
                private _reason = _y;
                _playerReportArray pushBack [_reporter, _reason];
            } forEach _playerReports;

            private _playerData = [_uid, _playerName, _fullDisplayString, _playerReportArray];
            private _playerDataJson = toJSON _playerData;
            _playerDataJson = _texture ctrlWebBrowserAction ["ToBase64", _playerDataJson];
            private _script = format [
                "updatePlayerInfo(atob(""%1""));",  
                _playerDataJson
            ];
            _texture ctrlWebBrowserAction ["ExecJS", _script];
        };
        case "timeout": {
            private _uid = _message select 1;
            private _duration = _message select 2;
            private _reason = _message select 3;

            private _existingInfoDisplay = profileNamespace getVariable ["WL2_infoDisplay", ""];
            private _infoDisplayText = uiNamespace getVariable ["WL2_currentModDisplayString", ""];
            private _banText = format ["%1%5%2%5[DURATION] %3 MIN%5[REASON] %4%5", _existingInfoDisplay, _infoDisplayText, _duration, _reason, endl];
            profileNamespace setVariable ["WL2_infoDisplay", _banText];

            _duration = _duration * 60;
            [player, _uid, _reason, _duration] remoteExec ["WL2_fnc_punishPlayer", 2];
        };
        case "rebalance": {
            private _uid = _message select 1;
            [player, _uid] remoteExec ["WL2_fnc_rebalance", 2];
        };
        case "accessVehicles": {
            private _uid = _message select 1;
            uiNamespace setVariable ["WL2_modOverrideUid", _uid];
            0 spawn WL2_fnc_vehicleManager;
        };
        case "gotoPlayer": {
            private _uid = _message select 1;
            private _selectedPlayer = [_uid] call BIS_fnc_getUnitByUID;
            if (isNull _selectedPlayer) exitWith { true };
            cameraOn setVehiclePosition [_selectedPlayer modelToWorld [0, 0, 0], [], 3, "NONE"];
        };
        case "seeTransfers": {
            private _uid = _message select 1;
            private _selectedPlayer = [_uid] call BIS_fnc_getUnitByUID;
            if (isNull _selectedPlayer) exitWith { true };
            private _transferHistory = _selectedPlayer getVariable ["WL2_playerTransfers", []];
            [_texture, str _transferHistory] spawn MENU_fnc_copyChat;
        };
        case "clearReports": {
            private _uid = _message select 1;
            private _selectedPlayer = [_uid] call BIS_fnc_getUnitByUID;
            if (isNull _selectedPlayer) exitWith { true };
            [] remoteExec ["WL2_fnc_clearPlayerReports", _selectedPlayer];
        };
        case "modReceipts": {
            private _infoDisplay = profileNamespace getVariable ["WL2_infoDisplay", ""];
            [_texture, _infoDisplay] spawn MENU_fnc_copyChat;
            profileNamespace setVariable ["WL2_infoDisplay", ""];
        };
        case "clearTimeout": {
            private _uid = _message select 1;
            [player, _uid] remoteExec ["WL2_fnc_clearTimeout", 2];
        };
    };

    true;
}];

_texture ctrlAddEventHandler ["PageLoaded", {
    _this spawn {
        params ["_texture"];        
        private _playerAliases = profileNamespace getVariable ["WL2_playerAliases", createHashMap];
        while { !isNull _texture } do {
            private _allPlayers = call BIS_fnc_listPlayers;
            _allPlayers = [_allPlayers, [], { [_x] call BIS_fnc_getName }, "ASCEND"] call BIS_fnc_sortBy;

            private _playerData = _allPlayers apply {
                private _player = _x;
                private _playerUid = getPlayerUID _player;
                private _playerName = [_player] call BIS_fnc_getName;

                private _playerNames = _playerAliases getOrDefault [_playerUid, []];
                private _playerAliases = _playerNames select {
                    _x != _playerName && _x != ""
                };

                private _playerReports = _player getVariable ["WL2_playerReports", createHashMap];
                [_playerUid, _playerName, _playerAliases, count _playerReports]
            };
            private _playerDataJson = toJSON _playerData;
            _playerDataJson = _texture ctrlWebBrowserAction ["ToBase64", _playerDataJson];

            private _chatHistory = uiNamespace getVariable ["WL2_chatHistory", []];
            private _squadChannels = missionNamespace getVariable ["SQD_VoiceChannels", [-1, -1]];
            private _chatHistoryData = _chatHistory apply {
                private _channel = _x # 0;
                private _name = _x # 1;
                private _text = _x # 2;
                private _systemTime = _x # 3;

                private _channelDisplay = switch (_channel) do {
                    case 0: { "GLOBAL" };
                    case 1: { "SIDE" };
                    case 2: { "COMMAND" };
                    case 3: { "GROUP" };
                    case 4: { "VEHICLE" };
                    case 5: { "DIRECT" };
                    case 6;
                    case 16: { "SYSTEM" };
                    case (_squadChannels # 0 + 5);
                    case (_squadChannels # 1 + 5): { "SQUAD" };
                    default { "UNKNOWN" };
                };
                private _systemTimeDisplay = [_systemTime, false] call MENU_fnc_printSystemTime;
                [_systemTimeDisplay, _channelDisplay, _name, _text]
            };
            private _chatHistoryJson = toJSON _chatHistoryData;
            _chatHistoryJson = _texture ctrlWebBrowserAction ["ToBase64", _chatHistoryJson];

            private _punishmentCollection = missionNamespace getVariable ["WL2_punishmentCollection", []];
            private _punishData = _punishmentCollection select { _x # 1 > serverTime } apply {
                private _uid = _x # 0;
                private _endTime = _x # 1;
                [_uid, round (_endTime - serverTime)]
            };
            private _timeoutJson = toJSON _punishData;
            _timeoutJson = _texture ctrlWebBrowserAction ["ToBase64", _timeoutJson];

            private _playerUid = getPlayerUID player;
            private _isAdmin = _playerUid in getArray (missionConfigFile >> "adminIDs");
            private _setAdmin = if (_isAdmin) then {
                "document.isAdmin = true;"
            } else { "" };


            private _script = format [
                "updatePlayers(atob(""%1""));updateChat(atob(""%2""));updateTimeouts(atob(""%3""));%4",
                _playerDataJson,
                _chatHistoryJson,
                _timeoutJson,
                _setAdmin
            ];
            _texture ctrlWebBrowserAction ["ExecJS", _script];

            sleep 5;
        };
    };
}];