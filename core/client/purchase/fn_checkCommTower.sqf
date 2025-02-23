#include "..\..\warlords_constants.inc"

params ["_class"];

if (_class != "Land_Communication_F") exitWith {
    [true, ""];
};

private _allTowersOnTeam = ("Land_Communication_F" allObjects 0) select {
    [_x] call WL2_fnc_getAssetSide != BIS_WL_playerSide
};
private _jammersNear = _allTowersOnTeam select { player distance _x < (WL_JAMMER_RANGE_OUTER * 2) };

if (count _jammersNear > 0) exitWith {
    [false, localize "STR_A3_WL_jammer_restr"];
};

private _homeBase = BIS_WL_playerSide call WL2_fnc_getSideBase;
private _isInHomeBase = player inArea (_homeBase getVariable "objectAreaComplete");
if (_isInHomeBase) exitWith {
    [false, localize "STR_A3_WL_jammer_home_restr"];
};

[true, ""]