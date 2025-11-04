#include "includes.inc"
params ["_unit"];

_unit setVelocity [0, 0, 0];
#if __GAME_BUILD__ <= 153351
{
    _x setCaptive true;
    _x setUnconscious true;
} forEach (units _unit);
#endif

_unit setCaptive true;
_unit setUnconscious true;

_unit setVariable ["WL2_expirationTime", serverTime + 30, true];

private _startTime = serverTime;
private _downTime = 0;
while { alive _unit && lifeState _unit == "INCAPACITATED" } do {
    if (animationState _unit != "Acts_StaticDeath_02") then {
        [_unit, ["Acts_StaticDeath_02"]] remoteExec ["switchMove", 0];
    };

    _downTime = serverTime - _startTime;
    setPlayerRespawnTime ((30 - _downTime) max 1);

    private _expirationTime = _unit getVariable ["WL2_expirationTime", serverTime + 30];
    if (serverTime > _expirationTime) then {
        forceRespawn _unit;
        break;
    };

    _unit setVariable ["WL_unconsciousTime", _downTime];
    uiSleep 0.1;
};