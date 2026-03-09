#include "includes.inc"

while { !BIS_WL_missionEnd } do {
    {
        if (speed _x < 10) then {
            continue;
        };
        private _velocity = velocity _x;
        _velocity set [0, 0];
        _velocity set [1, 0];
        _x setVelocity _velocity;
    } forEach allDead;

    uiSleep 5;
};