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

["TaskPlaceTent"] call WLT_fnc_taskComplete;

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

deleteVehicle _projectile;