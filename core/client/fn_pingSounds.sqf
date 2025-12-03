#include "includes.inc"
params ["_firstTime"];
private _pingSound = "a3\ui_f_curator\data\sound\cfgsound\ping01.wss";

private _C5 = 1.1892;
private _D5 = 1.3348;
private _E5 = 1.4983;
private _F5 = 1.5874;
private _G5 = 1.7818;

private _short = 0.4;
private _med = 0.8;
private _long = 1.2;
private _longer = 1.4;

private _notes = [
    [_E5, _short],
    [_E5, _short],
    [_E5, _med],

    [_E5, _short],
    [_E5, _short],
    [_E5, _med],

    [_E5, _short],
    [_G5, _short],
    [_C5, _short],
    [_D5, _short],
    [_E5, _long],

    [_F5, _short],
    [_F5, _short],
    [_F5, _short],
    [_F5, _short],

    [_F5, _short],
    [_E5, _short],
    [_E5, _short],
    [_E5, _short],

    [_E5, _short],
    [_D5, _short],
    [_D5, _short],
    [_E5, _short],
    [_D5, _med],
    [_G5, _med],

    [_E5, _short],
    [_E5, _short],
    [_E5, _med],

    [_E5, _short],
    [_E5, _short],
    [_E5, _med],

    [_E5, _short],
    [_G5, _short],
    [_C5, _short],
    [_D5, _short],
    [_E5, _long],

    [_F5, _short],
    [_F5, _short],
    [_F5, _short],
    [_F5, _short],

    [_F5, _short],
    [_E5, _short],
    [_E5, _short],
    [_E5, _short],

    [_G5, _short],
    [_G5, _short],
    [_F5, _short],
    [_D5, _short],
    [_C5, _longer]
];

if (!_firstTime) then {
    _notes = _notes select [44, 5];
};

{
    private _pitch = _x # 0;
    private _delay = _x # 1;

    playSoundUI [_pingSound, 2, _pitch];
    uiSleep _delay;
} forEach _notes;