#include "..\..\warlords_constants.inc"
private _collabCooldown = missionNamespace getVariable ["WL2_collaboratorCooldown", 0];
if (serverTime < _collabCooldown) exitWith {
    private _cooldownText = localize "STR_SQUADS_cooldown";
    private _timeoutDisplay = [_collabCooldown - serverTime, "MM:SS"] call BIS_fnc_secondsToString;
    [false, format [_cooldownText, _timeoutDisplay]];
};
[true, ""];