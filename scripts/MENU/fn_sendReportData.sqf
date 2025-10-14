#include "includes.inc"
params ["_texture"];
private _playerAliases = profileNamespace getVariable ["WL2_playerAliases", createHashMap];

private _allPlayers = call BIS_fnc_listPlayers;
_allPlayers = [_allPlayers, [], { [_x] call BIS_fnc_getName }, "ASCEND"] call BIS_fnc_sortBy;

private _playerData = _allPlayers apply {
    private _player = _x;
    private _playerUid = getPlayerUID _player;
    private _playerName = [_player] call BIS_fnc_getName;
    [_playerUid, _playerName]
};
private _playerDataJson = toJSON _playerData;
_playerDataJson = _texture ctrlWebBrowserAction ["ToBase64", _playerDataJson];

private _script = format [
    "updatePlayers(atob(""%1""));",
    _playerDataJson
];
_texture ctrlWebBrowserAction ["ExecJS", _script];