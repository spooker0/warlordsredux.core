#include "includes.inc"
params ["_texture"];
private _playerAliases = profileNamespace getVariable ["WL2_playerAliases", createHashMap];

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

private _punishmentMap = missionNamespace getVariable ["WL2_punishmentMap", createHashMap];
private _punishData = [];
{
    private _uid = _x;
    private _incidentData = _y;

    private _endTime = _incidentData # 0;
    if (_endTime < serverTime) then {
        continue;
    };
    private _reason = _incidentData # 1;
    _punishData pushBack [_uid, round (_endTime - serverTime), _reason];
} forEach _punishmentMap;

private _timeoutJson = toJSON _punishData;
_timeoutJson = _texture ctrlWebBrowserAction ["ToBase64", _timeoutJson];

private _modReceipts = profileNamespace getVariable ["WL2_infoDisplay", ""];
_modReceipts = _texture ctrlWebBrowserAction ["ToBase64", _modReceipts];

private _playerUid = getPlayerUID player;
private _isAdmin = _playerUid in getArray (missionConfigFile >> "adminIDs");
private _setAdmin = if (_isAdmin) then {
    "document.isAdmin = true;"
} else { "" };


private _script = format [
    "updatePlayers(atob(""%1""));updateChat(atob(""%2""));updateTimeouts(atob(""%3""));updateModReceipts(atob(""%4""));%5",
    _playerDataJson,
    _chatHistoryJson,
    _timeoutJson,
    _modReceipts,
    _setAdmin
];
_texture ctrlWebBrowserAction ["ExecJS", _script];