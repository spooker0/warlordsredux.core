#include "includes.inc"
private _findCurrentSector = (BIS_WL_sectorsArray # 0) select {
    player inArea (_x getVariable "objectAreaComplete")
};

if (count _findCurrentSector == 0) exitWith {
    [false, localize "STR_A3_WL_menu_arsenal_restr1"];
};

#if WL_STRONGHOLD_DEBUG == 0
private _timeSinceStart = WL_DURATION_MISSION - (estimatedEndServerTime - serverTime);
private _strongholdTimer =  60 * 30;
if (_timeSinceStart < _strongholdTimer) exitWith {
    [false, format ["You cannot create a stronghold until %1 minutes into the mission.", round (_strongholdTimer / 60)]];
};
#endif

private _currentSector = _findCurrentSector # 0;

private _isCarrierSector = _currentSector getVariable ["WL2_isAircraftCarrier", false];
if (_isCarrierSector) exitWith {
    [false, "You cannot put a stronghold in a carrier sector."];
};

#if WL_STRONGHOLD_DEBUG == 0
private _isHomeBase = _currentSector in [WL2_base1, WL2_base2];
if (_isHomeBase) exitWith {
    [false, "You cannot put a stronghold in your home base."];
};
#endif

private _findStrongholdBuildings = call WL2_fnc_findStrongholdBuilding;
if (count _findStrongholdBuildings == 0) exitWith {
    [false, "You are not in/near a building that can be made into a stronghold."];
};

[true, ""];