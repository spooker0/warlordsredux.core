#include "includes.inc"
// Cooldown check
private _paradropNextUse = (vehicle player) getVariable ["WL2_paradropNextUse", 0];
if (serverTime < _paradropNextUse) exitWith {
    private _cooldownText = localize "STR_SQUADS_cooldown";
    private _timeoutDisplay = [_paradropNextUse - serverTime, "MM:SS"] call BIS_fnc_secondsToString;
    [false, format [_cooldownText, _timeoutDisplay]];
};

private _lastDamageTime = (vehicle player) getEntityInfo 5;
if (_lastDamageTime > 0 && _lastDamageTime < WL_COOLDOWN_PARADROP_DMG) exitWith {
    private _damageCooldownText = "Damaged too recently: %1";
    private _timeoutDisplay = [(WL_COOLDOWN_PARADROP_DMG - _lastDamageTime), "MM:SS"] call BIS_fnc_secondsToString;
    [false, format [_damageCooldownText, _timeoutDisplay]];
};

[true, ""];