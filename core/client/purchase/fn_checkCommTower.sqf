#include "..\..\warlords_constants.inc"

params ["_class"];

if (_class != "Land_MobileRadar_01_radar_F") exitWith {
    [true, ""];
};

private _allTowersOnTeam = ("Land_MobileRadar_01_radar_F" allObjects 0) select {
    [_x] call WL2_fnc_getAssetSide != BIS_WL_playerSide
};
private _jammersNear = _allTowersOnTeam select { player distance _x < (WL_JAMMER_RANGE_OUTER * 2) };

if (count _jammersNear > 0) exitWith {
    [false, localize "STR_A3_WL_jammer_restr"];
};

[true, ""]