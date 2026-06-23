#include "includes.inc"
params ["_driverProxy"];

if !(WL_ISUP(player)) then {
    setPlayerRespawnTime 0.1;
    forceRespawn player;

    waitUntil {
        uiSleep 0.1;
        WL_ISUP(player);
    };
};

switchCamera _driverProxy;
player remoteControl _driverProxy;
(vehicle _driverProxy) setEffectiveCommander _driverProxy;
uiNamespace setVariable ["WL2_canBuy", false];

private _startTime = serverTime;
while { WL_ISUP(_driverProxy) && WL_ISUP(player) } do {
    uiSleep 1;
};

uiSleep 5;
player remoteControl objNull;
uiNamespace setVariable ["WL2_canBuy", true];