params ["_stronghold", "_currentSector"];

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

[_stronghold, true] remoteExec ["WL2_fnc_protectStronghold", 0, true];