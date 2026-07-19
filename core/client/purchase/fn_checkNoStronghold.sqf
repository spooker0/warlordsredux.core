#include "includes.inc"

private _teamSectorsData = WL_SECTORS_DATA(BIS_WL_playerSide);
private _linkedSectors = _teamSectorsData getOrDefault ["linked", []];

private _findCurrentSector = _linkedSectors select {
    player inArea (_x getVariable "objectAreaComplete")
};

if (count _findCurrentSector == 0) exitWith {
    [false, localize "STR_A3_WL_menu_arsenal_restr1"];
};

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

private _strongholdAllowTime = _currentSector getVariable ["WL2_strongholdAllowTime", 0];
if (serverTime < _strongholdAllowTime) exitWith {
    private _cooldownText = [_strongholdAllowTime - serverTime, "MM:SS"] call BIS_fnc_secondsToString;
    [false, format ["This sector's stronghold is on cooldown: %1", _cooldownText]];
};

private _findStrongholdBuildings = [getPosATL player, 50, false] call WL2_fnc_findStrongholdBuilding;
if (count _findStrongholdBuildings == 0) exitWith {
    [false, "You are not in/near a building that can be made into a stronghold."];
};

[true, ""];