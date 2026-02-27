#include "includes.inc"

call WL2_fnc_ewarGenerate;

while { !BIS_WL_missionEnd } do {
    private _signalWest = missionNamespace getVariable ["WL2_ewarSignal_west", 500];
    private _signalEast = missionNamespace getVariable ["WL2_ewarSignal_east", 500];

    private _signalDecay = 20;
    _signalWest = if (_signalWest > 500) then { (_signalWest - _signalDecay) max 500 } else { (_signalWest + _signalDecay) min 500 };
    _signalEast = if (_signalEast > 500) then { (_signalEast - _signalDecay) max 500 } else { (_signalEast + _signalDecay) min 500 };

    missionNamespace setVariable ["WL2_ewarSignal_west", _signalWest, true];
    missionNamespace setVariable ["WL2_ewarSignal_east", _signalEast, true];

    uiSleep 60;
};