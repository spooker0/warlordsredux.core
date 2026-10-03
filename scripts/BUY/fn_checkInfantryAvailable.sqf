#include "includes.inc"
params ["_className"];

if (_className isKindOf "Man" && BIS_WL_matesAvailable <= 0) exitWith {
    [false, localize "STR_A3_WL_airdrop_restr2"]
};

if (_className == "BuildABear" && BIS_WL_matesAvailable <= 0) exitWith {
    [false, localize "STR_A3_WL_airdrop_restr2"]
};

[true, ""];
