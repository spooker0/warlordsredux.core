#include "includes.inc"
params ["_shooter", "_originatorUid"];

if (isNil "_originatorUid") exitWith {};

private _reward = 300;
private _compensation = 50;

private _shooterUid = _shooter getVariable ["BIS_WL_ownerAsset", "123"];
private _originator = _originatorUid call BIS_fnc_getUnitByUID;

private _originatorSide = side group _originator;

if (_originatorSide == side group _shooter) then {
    _reward = 0;
    _compensation = 0;
};

if (isPlayer _shooter) then {
    [_reward, _shooterUid] call WL2_fnc_fundsDatabaseWrite;
    [objNull, _reward, "Projectile destroyed", "#de0808"] remoteExec ["WL2_fnc_killRewardClient", _shooter];
};

if (isPlayer _originator) then {
    [_compensation, _originatorUid] call WL2_fnc_fundsDatabaseWrite;
    [objNull, _compensation, "Projectile jammed", "#de0808"] remoteExec ["WL2_fnc_killRewardClient", _originator];
};

[[_shooter], 60] remoteExec ["WL2_fnc_reportTargets", _originatorSide];