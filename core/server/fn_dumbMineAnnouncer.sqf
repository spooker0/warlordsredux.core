#include "includes.inc"
missionNamespace setVariable ["WL2_mineExplosion", false];
private _mineVictims = 0;
while { !BIS_WL_missionEnd } do {
    uiSleep 5;

    private _mineExplosion = missionNamespace getVariable ["WL2_mineExplosion", false];
    if (_mineExplosion) then {
        missionNamespace setVariable ["WL2_mineExplosion", false];
        _mineVictims = _mineVictims + 1;
        private _message = format ["Beware! Independent minefield has claimed a victim (%1 so far).", _mineVictims];
        [_message] remoteExec ["WL2_fnc_broadcastAction", -2];
    };
};