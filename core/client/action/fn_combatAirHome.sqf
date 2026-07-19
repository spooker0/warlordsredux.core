#include "includes.inc"

private _timeSinceStart = WL_DURATION_MISSION - (estimatedEndServerTime - serverTime);
if (_timeSinceStart < WL_COMBAT_AIR_HOME_TIME) exitWith {
    playSoundUI ["AddItemFailed"];
    ["No-fly zone is not available for home base yet."] call WL2_fnc_smoothText;
};

private _sector = [BIS_WL_playerSide] call WL2_fnc_getSideBase;
private _sectorCombatAirActive = _sector getVariable ["WL2_combatAirActive", false];
if (_sectorCombatAirActive) exitWith {
    playSoundUI ["AddItemFailed"];
    ["Your home base is already a no-fly zone!"] call WL2_fnc_smoothText;
};

private _sectorNextCombatAirTime = _sector getVariable ["WL2_nextCombatAir", -9999];
if (_sectorNextCombatAirTime > serverTime) exitWith {
    playSoundUI ["AddItemFailed"];
    ["Your home base is on cooldown for a no-fly zone!"] call WL2_fnc_smoothText;
};

private _cost = WL_COST_COMBATAIR / 5;
private _cooldown = WL_COOLDOWN_CAPHOME;

private _message = format [
    "Are you sure you want to establish a no-fly zone over home base? This will cost you %1%2 and put it on a %3 minute cooldown.",
    WL_MONEY_SIGN, _cost, round (_cooldown / 60)
];
private _result = [localize "STR_WL_combatAirPatrol", _message, "OK", "Cancel"] call WL2_fnc_prompt;
if (!_result) exitWith {
    playSoundUI ["AddItemFailed"];
};

[player, "combatAirHome", BIS_WL_playerSide, _sector] remoteExec ["WL2_fnc_handleClientRequest", 2];
playSoundUI ["a3\dubbing_f_jets\showcase_jets\30_reinforcements\showcase_jets_30_reinforcements_tower_0.wss"];