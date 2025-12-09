#include "includes.inc"
params ["_firstTime"];

private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];
private _eventMusicVolume = _settingsMap getOrDefault ["eventMusicVolume", 1];
if (_eventMusicVolume <= 0) exitWith {};

private _pingSound = "a3\ui_f_curator\data\sound\cfgsound\ping01.wss";

private _C5 = 1.1892;
private _D5 = 1.3348;
private _E5 = 1.4983;
private _F5 = 1.5874;
private _G5 = 1.7818;

private _short = 0.3;
private _med = 0.6;
private _long = 0.9;

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
    [_C5, _long]
];

if (!_firstTime) then {
    _notes = _notes select [44, 5];
};

{
    private _pitch = _x # 0;
    private _delay = _x # 1;

    playSoundUI [_pingSound, 2 * _eventMusicVolume, _pitch];
    uiSleep _delay;
} forEach _notes;