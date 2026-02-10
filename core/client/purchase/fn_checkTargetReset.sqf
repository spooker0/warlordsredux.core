#include "includes.inc"
private _side = BIS_WL_playerSide;
private _timeout = WL_COOLDOWN_TARGETRESET;
private _targetResetTime = missionNamespace getVariable ["WL_targetResetTime", -_timeout];
if (serverTime - _targetResetTime < _timeout) exitWith {
    private _cooldownText = [_timeout - (serverTime - _targetResetTime), "MM:SS"] call BIS_fnc_secondsToString;
    [false, _cooldownText];
};
[true, ""];