#include "includes.inc"
params ["_badgeName"];
if (isDedicated) exitWith {};
private _badges = profileNamespace getVariable ["WL2_badges", createHashMap];
[_badgeName] call RWD_fnc_newBadge;
private _currentBadges = _badges getOrDefault [_badgeName, 0];
_badges set [_badgeName, (_currentBadges + 1) min 50];
profileNamespace setVariable ["WL2_badges", _badges];