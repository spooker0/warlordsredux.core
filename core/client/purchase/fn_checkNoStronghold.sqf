#include "..\..\warlords_constants.inc"

private _findCurrentSector = (BIS_WL_sectorsArray # 0) select {
    player inArea (_x getVariable "objectAreaComplete")
};

if (count _findCurrentSector == 0) exitWith {
    [false, localize "STR_A3_WL_menu_arsenal_restr1"];
};

private _findStrongholdBuildings = call WL2_fnc_findStrongholdBuilding;
if (count _findStrongholdBuildings == 0) exitWith {
    [false, "You are not in/near a building that can be made into a stronghold."];
};

[true, ""];