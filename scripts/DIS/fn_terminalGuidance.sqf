#include "includes.inc"
params ["_projectile", "_unit"];

[_projectile, _unit] call DIS_fnc_startMissileCamera;

_projectile addEventHandler ["SubmunitionCreated", {
	params ["_projectile", "_submunitionProjectile", "_position", "_velocity"];
    [_submunitionProjectile] spawn DIS_fnc_seekTerminal;
}];

waitUntil {
    sleep 0.1;
    private _altitude = getPosATL _projectile # 2;
    _altitude > 500 || !alive _projectile;
};
waitUntil {
    sleep 0.1;
    private _altitude = getPosATL _projectile # 2;
    _altitude < 500 || !alive _projectile;
};

if !(_projectile isKindOf "SubmunitionBase") then {
    [_projectile] call DIS_fnc_seekTerminal;
};