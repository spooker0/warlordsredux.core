#include "includes.inc"
params ["_badgeName", ["_unique", false], ["_remove", false]];
if (isDedicated) exitWith {};
private _badges = profileNamespace getVariable ["WL2_badges", createHashMap];

private _silent = false;
private _currentBadges = _badges getOrDefault [_badgeName, 0];
private _newBadgeNum = _currentBadges + 1;
if (_unique) then {
    if (_currentBadges > 0) then {
        _silent = true;
    };
    _newBadgeNum = 1;
};
if (_remove) then {
    _newBadgeNum = 0;
    _silent = true;
    private _currentBadge = player getVariable ["WL2_currentBadge", ""];
    if (_currentBadge == _badgeName) then {
        profileNamespace setVariable ["WL2_currentBadge", "Player"];
        player setVariable ["WL2_currentBadge", "Player", true];
    };
};
_badges set [_badgeName, _newBadgeNum min 50];
profileNamespace setVariable ["WL2_badges", _badges];

if (!_silent) then {
    [_badgeName] call RWD_fnc_newBadge;
};