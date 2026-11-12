#include "includes.inc"

private _timeSinceStart = WL_DURATION_MISSION - (estimatedEndServerTime - serverTime);
if (_timeSinceStart < WL_COMBAT_AIR_HOME_TIME) exitWith {
    private _timeRemaining = [WL_COMBAT_AIR_HOME_TIME - _timeSinceStart, "MM:SS"] call BIS_fnc_secondsToString;
    [false, format [localize "STR_WL_homeNoFlyZoneNotAvailableYet", _timeRemaining]];
};

private _sector = [BIS_WL_playerSide] call WL2_fnc_getSideBase;
private _sectorCombatAirActive = _sector getVariable ["WL2_combatAirActive", false];
if (_sectorCombatAirActive) exitWith {
    [false, localize "STR_WL_homeNoFlyZoneAlreadyActive"];
};

private _sectorNextCombatAirTime = _sector getVariable ["WL2_nextCombatAir", -9999];
if (_sectorNextCombatAirTime > serverTime) exitWith {
    [false, localize "STR_WL_homeNoFlyZoneCooldown"];
};

[true, ""];
