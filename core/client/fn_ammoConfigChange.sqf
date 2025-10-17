#include "includes.inc"
while { !BIS_WL_missionEnd } do {
    if (cameraOn != player) then {
        [cameraOn] call WL2_fnc_ammoConfigDetection;
    };
    uiSleep 2;
};