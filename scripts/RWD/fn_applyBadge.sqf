#include "includes.inc"
params ["_badgeName"];

systemChat format ["You have applied the badge: %1", _badgeName];
playSoundUI ["AddItemOk", 1];
profileNamespace setVariable ["WL2_currentBadge", _badgeName];
player setVariable ["WL2_currentBadge", _badgeName, true];

0 spawn WL2_fnc_updateLevelDisplay;