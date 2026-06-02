#include "includes.inc"
params ["_destroyer", "_sector"];

uiSleep 0.5;

private _reward = 500;
private _rewardText = "Destroyed stronghold";

if (isPlayer _destroyer) then {
    [_reward, getPlayerUID _destroyer, true, _rewardText] call WL2_fnc_fundsDatabaseWrite;
    [objNull, _reward, _rewardText, WL_COLOR_KILL] remoteExec ["WL2_fnc_killRewardClient", _destroyer];
};

private _sectorOwner = _sector getVariable ["BIS_WL_owner", sideUnknown];
if (_sectorOwner == independent) then {
    _sector setVariable ["WL2_sectorPop", 0, true];
};