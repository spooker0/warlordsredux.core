#include "includes.inc"
params ["_projectile"];

private _projectileType = typeOf _projectile;

waitUntil {
    uiSleep 0.5;
    !alive _projectile || (abs speed _projectile) < 0.1;
};

private _projectilePosition = getPosASL _projectile;
if (surfaceIsWater _projectilePosition && (_projectilePosition # 2) < -1) exitWith {
    deleteVehicle _projectile;
    systemChat "Respawn tent cannot be placed under water.";
};

private _previousRespawnBag = player getVariable ["WL2_respawnBag", objNull];
if (!isNull _previousRespawnBag) then {
    player setVariable ["WL2_respawnBag", objNull, [2, clientOwner]];
    deleteVehicle _previousRespawnBag;
};

private _pos = _projectile modelToWorld [0, 0, 0];
// _pos set [2, 0];

private _tentMap = createHashMapFromArray [
    ["Chemlight_blue", "Land_TentSolar_01_bluewhite_F"],
    ["Chemlight_green", "Land_TentDome_F"],
    ["Chemlight_red", "Land_TentSolar_01_redwhite_F"],
    ["Chemlight_yellow", "Land_TentA_F"]
];
private _tentType = _tentMap getOrDefault [_projectileType, "Land_TentA_F"];

private _freshTent = createVehicle [_tentType, _pos, [], 0, "NONE"];
_freshTent setVehiclePosition [_pos, [], 0, "CAN_COLLIDE"];

player setVariable ["WL2_respawnBag", _freshTent, [2, clientOwner]];

_freshTent enableWeaponDisassembly false;
playSoundUI ["a3\ui_f\data\sound\cfgnotifications\communicationmenuitemadded.wss"];

_freshTent setVariable ["WL2_demolitionHealth", 1, true];
_freshTent setVariable ["WL2_demolitionMaxHealth", 1, true];
_freshTent setVariable ["WL2_canDemolish", true, true];
_freshTent setVariable ["WL_spawnedAsset", true, true];
_freshTent setVariable ["BIS_WL_ownerAsset", getPlayerUID player, true];
_freshTent setVariable ["BIS_WL_ownerAssetSide", side group player, true];

private _ownedVehicleVar = format ["BIS_WL_ownedVehicles_%1", getPlayerUID player];
private _ownedVehicles = missionNamespace getVariable [_ownedVehicleVar, []];
_ownedVehicles pushBack _freshTent;
missionNamespace setVariable [_ownedVehicleVar, _ownedVehicles, true];

deleteVehicle _projectile;