#include "includes.inc"
params ["_shooter", "_ammoConsumption", "_target"];

private _reward = 50;
_reward = _reward * _ammoConsumption;

private _rewardText = "Active protection system";

private _shooterUid = _shooter getVariable ["BIS_WL_ownerAsset", "123"];
private _responsiblePlayer = _shooterUid call BIS_fnc_getUnitByUID;
if (isPlayer _responsiblePlayer) then {
    [_reward, _shooterUid] call WL2_fnc_fundsDatabaseWrite;
    [objNull, _reward, _rewardText, "#de0808"] remoteExec ["WL2_fnc_killRewardClient", _responsiblePlayer];

    _target setVariable ["WL_lastHitter", _responsiblePlayer, 2];
	{
		_x setVariable ["WL_lastHitter", _responsiblePlayer, 2];
	} forEach (crew _target);
};