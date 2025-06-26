#include "includes.inc"
params ["_shooter", "_originatorUid"];

if (isNil "_originatorUid") exitWith {};

private _reward = 300;

private _shooterUid = _shooter getVariable ["BIS_WL_ownerAsset", "123"];
private _originator = _originatorUid call BIS_fnc_getUnitByUID;

if (side group _originator == side group _shooter) then {
    _reward = 0;
};

if (isPlayer _shooter) then {
    [_reward, _shooterUid] call WL2_fnc_fundsDatabaseWrite;
    [objNull, _reward, "Projectile destroyed", "#de0808"] remoteExec ["WL2_fnc_killRewardClient", _shooter];
};