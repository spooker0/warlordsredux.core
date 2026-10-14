#include "includes.inc"
params ["_className"];

if !(_className isKindOf "Man" || _className == "BuildABear") exitWith {
    [true, ""]
};

private _maxSubordinates = missionNamespace getVariable ["WL2_maxSubordinates", 1];
if ((count units player - 1) >= _maxSubordinates) exitWith {
    [false, localize "STR_A3_WL_airdrop_restr2"]
};

[true, ""];