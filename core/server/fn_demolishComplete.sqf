#include "includes.inc"
params ["_target", "_caller"];

if !(isNull _caller) then {
    [_target, _caller] call WL2_fnc_killRewardHandle;
};
_target setVariable ["WL2_alreadyHandled", true];
_target setVariable ["WL_lastHitter", _caller];

uiSleep 0.5;

for "_i" from 1 to 10 do {
    if (random 1 > 0.5) then {
        continue;
    };

    private _randomFile = round random [1, 6, 12];
    if (_randomFile < 10) then {
        _randomFile = format ["0%1", _randomFile];
    } else {
        _randomFile = str _randomFile;
    };

    playSound3D [format ["a3\sounds_f_orange\arsenal\explosives\debris_%1.wss", _randomFile], _target];
    uiSleep 0.2;
};

_target setDamage [1, true, _caller, _caller];

uiSleep 2;
deleteVehicle _target;