#include "includes.inc"
params ["_unit"];
if (_unit getVariable ["WL2_unconscious", false]) exitWith {};

private _originalDeathPos = getPosWorld _unit;

_unit setVelocity [0, 0, 0];

#if __GAME_BUILD__ > 153351
{
    _x disableAI "COMMAND";
} forEach (units group _unit);
#endif

_unit setCaptive true;
_unit setUnconscious true;
_unit setVariable ["WL2_unconscious", true, true];

private _capAreaModifiers = missionNamespace getVariable ["WL2_capAreaModifiers", [0, 0, 0]];
private _sideIndex = if (side group _unit == west) then { 0 } else { 1 };
private _controlledMod = _capAreaModifiers # _sideIndex;
_controlledMod = ((_controlledMod min 1) max 0.66);

_unit setVariable ["WL2_expirationTime", serverTime + WL_DURATION_RESPAWN * _controlledMod, true];

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

private _startTime = serverTime;
private _downTime = 0;
while { WL_ISDBNO(_unit) } do {
    if (animationState _unit != _deadAnimation) then {
        [_unit, [_deadAnimation]] remoteExec ["switchMove", 0];
    };
    if (_unit distance2D _originalDeathPos > 30) then {
        _unit setPosWorld _originalDeathPos;
        _unit setVelocity [0, 0, 0];
    };

    _downTime = serverTime - _startTime;
    setPlayerRespawnTime ((WL_DURATION_RESPAWN * _controlledMod - _downTime) max 1);

    private _expirationTime = _unit getVariable ["WL2_expirationTime", serverTime + WL_DURATION_RESPAWN * _controlledMod];
    if (serverTime > _expirationTime) then {
        forceRespawn _unit;
        break;
    };

    _unit setVariable ["WL_unconsciousTime", _downTime];
    uiSleep 0.1;
};