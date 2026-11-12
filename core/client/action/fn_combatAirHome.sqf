#include "includes.inc"

private _timeSinceStart = WL_DURATION_MISSION - (estimatedEndServerTime - serverTime);
if (_timeSinceStart < WL_COMBAT_AIR_HOME_TIME) exitWith {
    playSoundUI ["AddItemFailed"];
    [localize "STR_WL_homeNoFlyZoneNotAvailableYet"] call WL2_fnc_smoothText;
};

private _sector = [BIS_WL_playerSide] call WL2_fnc_getSideBase;
private _sectorCombatAirActive = _sector getVariable ["WL2_combatAirActive", false];
if (_sectorCombatAirActive) exitWith {
    playSoundUI ["AddItemFailed"];
    [localize "STR_WL_homeNoFlyZoneAlreadyActive"] call WL2_fnc_smoothText;
};

private _sectorNextCombatAirTime = _sector getVariable ["WL2_nextCombatAir", -9999];
if (_sectorNextCombatAirTime > serverTime) exitWith {
    playSoundUI ["AddItemFailed"];
    [localize "STR_WL_homeNoFlyZoneCooldown"] call WL2_fnc_smoothText;
};

private _cost = WL_COST_COMBATAIR / 5;
private _cooldown = WL_COOLDOWN_CAPHOME;

private _message = format [
    localize "STR_WL_combatAirHomeConfirm",
    WL_MONEY_SIGN, _cost, round (_cooldown / 60)
];
private _result = [localize "STR_WL_combatAirPatrol", _message, localize "STR_WL_ok", localize "STR_WL_cancel"] call WL2_fnc_prompt;
if (!_result) exitWith {
    playSoundUI ["AddItemFailed"];
};

[player, "combatAirHome", BIS_WL_playerSide, _sector] remoteExec ["WL2_fnc_handleClientRequest", 2];
playSoundUI ["a3\dubbing_f_jets\showcase_jets\30_reinforcements\showcase_jets_30_reinforcements_tower_0.wss"];