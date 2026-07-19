#include "includes.inc"

private _timeSinceStart = WL_DURATION_MISSION - (estimatedEndServerTime - serverTime);
if (_timeSinceStart < WL_COMBAT_AIR_HOME_TIME) exitWith {
    private _timeRemaining = [WL_COMBAT_AIR_HOME_TIME - _timeSinceStart, "MM:SS"] call BIS_fnc_secondsToString;
    [false, format ["No-fly zone is not available for home base yet. Available in: %1", _timeRemaining]];
};

private _sector = [BIS_WL_playerSide] call WL2_fnc_getSideBase;
private _sectorCombatAirActive = _sector getVariable ["WL2_combatAirActive", false];
if (_sectorCombatAirActive) exitWith {
    [false, "Your home base is already a no-fly zone!"]
};

private _sectorNextCombatAirTime = _sector getVariable ["WL2_nextCombatAir", -9999];
if (_sectorNextCombatAirTime > serverTime) exitWith {
    [false, "Your home base is on cooldown for a no-fly zone!"]
};

[true, ""];