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

sleep 1;

playSoundUI ["a3\dubbing_f_tank\ta_tanks_m01\045_eve_earthquake\ta_tanks_m01_045_eve_earthquake_arplayer_0.ogg", 3, 1, true, 0.3];

sleep 7;

addCamShake [20, 20, 30];
playsound "Earthquake_04";

sleep 8;

addCamShake [10, 20, 30];
playsound "Earthquake_03";