#include "includes.inc"
params ["_launcher", "_target", "_damage", "_launcherUid"];

{
    private _newCrewDamage = damage _x + 0.2;
    _x setDamage [_newCrewDamage, true, _launcher, _launcher];
} forEach (crew _target);

private _newDamage = damage _target + _damage;
_target setDamage [_newDamage, true, _launcher, _launcher];

[_damage, _target] remoteExec ["WL2_fnc_samHit", _target];

private _reward = round (_damage * 100);
[objNull, _reward, "Aircraft damaged", WL_COLOR_KILL] remoteExec ["WL2_fnc_killRewardClient", _launcher];
[_reward, _launcherUid, true, "Aircraft damaged"] call WL2_fnc_fundsDatabaseWrite;