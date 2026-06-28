#include "includes.inc"
params ["_projectile", "_unit", "_mineLayerType"];

private _munitionList = _unit getVariable ["DIS_munitionList", []];
_munitionList pushBack _projectile;
_munitionList = _munitionList select { alive _x };
_unit setVariable ["DIS_munitionList", _munitionList];
_projectile setVariable ["WL2_missileType", "Deployer", true];

waitUntil {
    private _velocity = velocity _projectile;
    (_velocity # 2) < -1 || !alive _projectile
};
waitUntil {
    private _posAGL = _projectile modelToWorld [0, 0, 0];
    (_posAGL # 2) < 5 || !alive _projectile
};

if (isNull _projectile) exitWith {};

private _projectilePosition = _projectile modelToWorld [0, 0, 0];
private _projectileDirection = getDir _projectile;

deleteVehicle _projectile;

uiSleep 1;

[player, "deployMineLayer", _projectilePosition, _projectileDirection, _mineLayerType] remoteExec ["WL2_fnc_handleClientRequest", 2];