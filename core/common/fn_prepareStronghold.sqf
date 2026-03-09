#include "includes.inc"
params ["_stronghold", "_sector"];

_stronghold setDamage 0;
private _hitPoints = getAllHitPointsDamage _stronghold;
private _allHitPointNames = if (count _hitPoints > 0) then {
    _hitPoints # 0;
} else {
    [];
};
private _windowHitPointNames = _allHitPointNames select { "glass" in toLower _x || "window" in toLower _x };
{
    _stronghold setHitPointDamage [_x, 1];
} forEach _windowHitPointNames;
forceHitPointsDamageSync _stronghold;

private _sectorOwner = _sector getVariable ["BIS_WL_owner", independent];
private _maxHealth = if (_sectorOwner == independent) then {
    private _sectorValue = _sector getVariable ["BIS_WL_value", 50];
    private _strongholdStrength = linearConversion [5, 25, _sectorValue, 4, 13, true];
    round _strongholdStrength;
} else {
    8
};
_stronghold setVariable ["WL2_demolitionMaxHealth", _maxHealth, true];
_stronghold setVariable ["WL2_demolitionHealth", _maxHealth, true];

[_stronghold, true] remoteExec ["WL2_fnc_protectStronghold", 0, true];