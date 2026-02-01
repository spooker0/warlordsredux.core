#include "includes.inc"
params ["_destroyer", "_sector"];

private _reward = 500;
private _rewardText = "Destroyed Stronghold";

if (isPlayer _destroyer) then {
    [_reward, getPlayerUID _destroyer] call WL2_fnc_fundsDatabaseWrite;
    [objNull, _reward, _rewardText, "#de0808"] remoteExec ["WL2_fnc_killRewardClient", _destroyer];
};

private _sectorOwner = _sector getVariable ["BIS_WL_owner", sideUnknown];
if (_sectorOwner == independent) then {
    _sector setVariable ["WL2_sectorPop", 0, true];
};