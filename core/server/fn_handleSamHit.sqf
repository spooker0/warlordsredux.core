#include "includes.inc"
params ["_launcher", "_target", "_damage", "_projectilePosition"];

{
    private _newCrewDamage = damage _x + 0.2;
    _x setDamage [_newCrewDamage, true, _launcher, _launcher];
} forEach (crew _target);

private _newDamage = damage _target + _damage;
_target setDamage [_newDamage, true, _launcher, _launcher];

[_damage, _target] remoteExec ["WL2_fnc_samHit", _target];