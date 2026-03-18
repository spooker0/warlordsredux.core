#include "includes.inc"
params ["_target", "_caller"];

if (!local _target) exitWith {
    false
};

if (!alive _target) exitWith {
    false
};

if (player != _caller) exitWith {
    false
};

if (cursorObject != _target) exitWith {
    false
};

if (vehicle _caller != _caller) exitWith {
    false
};

private _apsAmmo = _target getVariable ["apsAmmo", -1];
private _maxAmmo = [_target] call APS_fnc_getMaxAmmo;
_apsAmmo < _maxAmmo;