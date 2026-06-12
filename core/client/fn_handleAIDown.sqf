#include "includes.inc"
params ["_unit"];

moveOut _unit;
_unit setCaptive true;
_unit setUnconscious true;
_unit setVariable ["WL2_unconscious", true, true];

private _originalDeathPos = getPosWorld _unit;

private _downedTime = serverTime;
private _unconsciousTime = _unit getVariable ["WL_unconsciousTime", 0];
if (_unconsciousTime > 0) exitWith {};
_unit setVariable ["WL2_expirationTime", serverTime + 90, true];

private _deadAnimations = [
    "Acts_StaticDeath_01",
    "Acts_StaticDeath_02",
    "Acts_StaticDeath_03",
    "Acts_StaticDeath_05",
    "Acts_StaticDeath_06",
    "Acts_StaticDeath_08",
    "Acts_StaticDeath_09"
];
private _deadAnimation = selectRandom _deadAnimations;

while { WL_ISDBNO(_unit) } do {
    if (animationState _unit != _deadAnimation) then {
        [_unit, [_deadAnimation]] remoteExec ["switchMove", 0];
    };
    if (_unit distance2D _originalDeathPos > 30) then {
        _unit setPosWorld _originalDeathPos;
        _unit setVelocity [0, 0, 0];
    };

    uiSleep 1;
    if (serverTime - _downedTime > 90) then {
        deleteVehicle _unit;
        break;
    };
};