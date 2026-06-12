#include "includes.inc"
params ["_unit", "_selection", "_damage", "_source", "_projectile", "_hitIndex", "_instigator", "_hitPoint", "_directHit"];

if (_hitPoint == "incapacitated") then {
    _damage = 0.8 min _damage;
};

if (_projectile isKindOf "MineCore" || _projectile isKindOf "TimeBombCore") then {
    private _instigator = [_source, _instigator] call WL2_fnc_handleInstigator;
    if (side group _instigator == side group _unit) then {
        _damage = _unit getHit _selection;
    };
};

if (_projectile == "") then {
    private _handledInstigator = [_source, _instigator] call WL2_fnc_handleInstigator;
    if (_handledInstigator != player && side group _handledInstigator == side group _unit) then {
        _damage = _unit getHit _selection;
    };
};

if (WL_ISUNCONSCIOUS(_unit)) exitWith {
    _damage min 0.99;
};

if (_damage < 1) exitWith {
    _damage;
};

[_unit] remoteExec ["WL2_fnc_handleAIDown", _unit];
[_unit, _source, _instigator] remoteExec ["WL2_fnc_handleEntityRemoval", 2];
0.99;