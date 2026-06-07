#include "includes.inc"
params ["_target", "_caller"];

if (vehicle _caller != _caller) exitWith {
    false
};

if (!alive _target) exitWith {
    false
};

private _hasAccess = ([_target, _caller, "full"] call WL2_fnc_accessControl) # 0;
if (!_hasAccess) exitWith {
    false
};

[getPosASL _caller, getDir _caller, 180, getPosASL _target] call WL2_fnc_inAngleCheck;