#include "includes.inc"

if ((getPosATL cameraOn) # 2 > 10) exitWith {};

0 spawn {
    private _startTime = serverTime;

    while { (serverTime - _startTime) < 25 } do {
        if (speed player > 12) then {
            player addForce [player vectorModelToWorld [0, -1, 0], player selectionPosition "rightfoot", false];
        };

        sleep 1;
    };
};

addCamShake [10, 20, 30];
playsound "Earthquake_03";

sleep 8;

"DynamicBlur" ppEffectEnable true;
"DynamicBlur" ppEffectAdjust [3];
"DynamicBlur" ppEffectCommit 1;

addCamShake [20, 20, 30];
playsound "Earthquake_04";

sleep 8;

"DynamicBlur" ppEffectAdjust [0];
"DynamicBlur" ppEffectCommit 10;

addCamShake [10, 20, 30];
playsound "Earthquake_03";

sleep 10;
"DynamicBlur" ppEffectEnable false;