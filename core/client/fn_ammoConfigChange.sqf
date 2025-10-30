#include "includes.inc"
while { !BIS_WL_missionEnd } do {
    [cameraOn] call WL2_fnc_ammoConfigDetection;
    uiSleep 0.2;
};