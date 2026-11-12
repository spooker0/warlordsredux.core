#include "includes.inc"
params ["_badgeName"];

private _badgeConfigs = call RWD_fnc_getBadgeConfigs;
private _badgeData = _badgeConfigs getOrDefault [_badgeName, []];
private _badgeDisplayName = _badgeData param [3, _badgeName];
[format [localize "STR_WL_badgeSelected", _badgeDisplayName]] call WL2_fnc_smoothText;
playSoundUI ["AddItemOk", 1];
missionProfileNamespace setVariable ["WL2_currentBadge", _badgeName];
player setVariable ["WL2_currentBadge", _badgeName, true];

0 spawn WL2_fnc_updateLevelDisplay;