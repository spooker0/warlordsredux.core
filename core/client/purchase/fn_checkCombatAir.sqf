#include "includes.inc"
private _ownedAirfieldSectors = (BIS_WL_sectorsArray # 2) select {
    private _services = _x getVariable ["WL2_services", []];
    "H" in _services;
};

private _timeSinceStart = WL_DURATION_MISSION - (estimatedEndServerTime - serverTime);
if (_timeSinceStart > WL_COMBAT_AIR_HOME_TIME) then {
    private _homeBase = [BIS_WL_playerSide] call WL2_fnc_getSideBase;
    _ownedAirfieldSectors pushBack _homeBase;
};

private _forwardBases = missionNamespace getVariable ["WL2_forwardBases", []];
private _ownedAirFobs = _forwardBases select {
    _x getVariable ["WL2_forwardBaseOwner", sideUnknown] == BIS_WL_playerSide
} select {
    private _defenseLevel = _x getVariable ["WL2_forwardBaseDefenseLevel", 0];
    _defenseLevel >= 4
};

private _eligibleCombatAirTargets = (_ownedAirfieldSectors + _ownedAirFobs) select {
    private _combatAirActive = _x getVariable ["WL2_combatAirActive", false];
    !_combatAirActive
} select {
    private _nextCombatAirTime = _x getVariable ["WL2_nextCombatAir", -9999];
    _nextCombatAirTime < serverTime
};

if (count _eligibleCombatAirTargets == 0) exitWith {
    [false, "No helipad sectors or forward airbases ready for no-fly zone operations!"];
};
[true, ""];