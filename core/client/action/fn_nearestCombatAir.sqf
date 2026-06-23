#include "includes.inc"

"RequestMenu_close" call WL2_fnc_setupUI;

private _ownedAirfieldSectors = (BIS_WL_sectorsArray # 2) select {
    private _services = _x getVariable ["WL2_services", []];
    "H" in _services;
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
    playSoundUI ["AddItemFailed"];
    ["No eligible targets for combat air support!"] call WL2_fnc_smoothText;
};

_eligibleCombatAirTargets = [_eligibleCombatAirTargets, [], { cameraOn distance _x }, "ASCEND"] call BIS_fnc_sortBy;
private _closestTarget = _eligibleCombatAirTargets # 0;
private _closestTargetName = _closestTarget getVariable ["WL2_name", "Forward Airbase"];

private _cost = WL_COST_COMBATAIR;
private _cooldown = WL_COOLDOWN_CAP;

private _message = format [
    "Are you sure you want to establish a no-fly zone over %1? This will cost you %2%3 and put it on a %4 minute cooldown.",
    _closestTargetName, WL_MONEY_SIGN, _cost, round (_cooldown / 60)
];
private _result = [localize "STR_WL_combatAirPatrol", _message, "OK", "Cancel"] call WL2_fnc_prompt;
if (!_result) exitWith {
    playSoundUI ["AddItemFailed"];
};

[player, "combatAir", BIS_WL_playerSide, _closestTarget] remoteExec ["WL2_fnc_handleClientRequest", 2];
playSoundUI ["a3\dubbing_f_jets\showcase_jets\30_reinforcements\showcase_jets_30_reinforcements_tower_0.wss"];