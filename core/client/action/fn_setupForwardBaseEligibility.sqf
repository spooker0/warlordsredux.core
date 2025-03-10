#include "..\..\warlords_constants.inc"
params ["_target", "_caller", "_upgrading"];

private _cursorObject = cursorObject;

private _spawned = _cursorObject getVariable ["WL_spawnedAsset", false];

if (!_spawned) exitWith {
    false
};

if (_caller != _caller) exitWith {
    false
};

private _playerFunds = (missionNamespace getVariable "fundsDatabaseClients") get (getPlayerUID player);
if (_upgrading && _playerFunds < 1000) exitWith {
    false
};

if (!_upgrading && typeof _cursorObject == "VirtualReammoBox_camonet_F") exitWith {
    ["isSquadLeaderOfSize", [getPlayerID player, 3]] call SQD_fnc_client &&
    alive _cursorObject &&
    player distance _cursorObject < WL_MAINTENANCE_RADIUS &&
    _cursorObject getVariable ["WL2_forwardBaseLevel", 0] == 0
};

if (_upgrading && typeof _cursorObject == "RuggedTerminal_01_communications_hub_F") exitWith {
    alive _cursorObject &&
    player distance _cursorObject < WL_MAINTENANCE_RADIUS &&
    _cursorObject getVariable ["WL2_forwardBaseTime", -1] < serverTime &&
    _cursorObject getVariable ["WL2_forwardBaseLevel", 0] < 3
};

false;