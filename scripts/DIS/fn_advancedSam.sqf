#include "includes.inc"
params ["_projectile", "_unit"];

_projectile setVariable ["WL2_missileNameOverride", "HERCULES", true];

private _target = _unit getVariable ["WL2_selectedTarget", objNull];
if (isNull _target) exitWith {
    [_projectile, _unit] spawn DIS_fnc_frag;
    [_projectile, _unit, 9300, 8000] spawn DIS_fnc_maneuver;
};

[_target, _unit, _projectile] remoteExec ["WL2_fnc_warnIncomingMissile", _target];
_projectile setMissileTarget [_target, true];

[_projectile, _unit] spawn DIS_fnc_frag;

private _targetAltitude = getPosASL _target # 2;
[_projectile, _unit, 14000, 8000, (_targetAltitude * 2) min 5000] spawn DIS_fnc_maneuver;