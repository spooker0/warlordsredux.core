#include "includes.inc"
params ["_badgeName"];

private _badgeConfigs = call RWD_fnc_getBadgeConfigs;
private _badgeData = _badgeConfigs getOrDefault [_badgeName, []];
if (count _badgeData == 0) exitWith {};
private _badges = uiNamespace getVariable ["WL2_badgeItems", []];
_badges pushBack [
	_badgeName,
	_badgeData # 2,
	_badgeData # 0,
	_badgeData # 1
];