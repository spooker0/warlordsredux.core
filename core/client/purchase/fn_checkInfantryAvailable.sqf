#include "..\..\warlords_constants.inc"

params ["_class"];

if (_class isKindOf "Man" && BIS_WL_matesAvailable <= 0) exitWith {
    [false, localize "STR_A3_WL_airdrop_restr2"]
};

if (_class == "BuildABear" && BIS_WL_matesAvailable <= 0) exitWith {
    [false, localize "STR_A3_WL_airdrop_restr2"]
};

[true, ""];