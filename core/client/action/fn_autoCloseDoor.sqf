#include "includes.inc"
params ["_target"];

private _startTime = serverTime;
_target setVariable ["WL2_doorCloseStartTime", _startTime, true];

uiSleep 10;

private _startTimeCurrent = _target getVariable ["WL2_doorCloseStartTime", -1];
if (_startTimeCurrent != _startTime) exitWith {};

if (!isNull _target) then {
    private _doorNumber = getNumber (configFile >> "CfgVehicles" >> typeOf _target >> "numberOfDoors");
    for "_i" from 1 to _doorNumber do {
        private _door = _i;

        private _doorPhase = _target animationSourcePhase (format ["Door_%1_sound_source", _door]);
        if (_doorPhase == 0) then {
            continue;
        };

        _target animateSource [format ["Door_%1_sound_source", _door], 0];
        _target animateSource [format ["Door_%1_noSound_source", _door], 0];

    };
};