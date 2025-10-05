#include "includes.inc"
params ["_projectile"];

waitUntil {
    sleep 0.5;
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

private _freshTent = createVehicle ["Land_TentA_F", _pos, [], 0, "NONE"];
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

deleteVehicle _projectile;