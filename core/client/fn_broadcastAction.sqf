#include "includes.inc"
params ["_message", ["_airHit", false]];
if (isDedicated) exitWith {};

[_message] call WL2_fnc_smoothText;

if (_airHit) then {
    private _sounds = [
        "a3\sounds_f\weapons\hits\glass_arm_1.wss",
        "a3\sounds_f\weapons\hits\glass_arm_2.wss",
        "a3\sounds_f\weapons\hits\glass_arm_3.wss",
        "a3\sounds_f\weapons\hits\glass_arm_4.wss",
        "a3\sounds_f\weapons\hits\glass_arm_5.wss",
        "a3\sounds_f\weapons\hits\glass_arm_6.wss",
        "a3\sounds_f\weapons\hits\glass_arm_7.wss",
        "a3\sounds_f\weapons\hits\glass_arm_8.wss",
        "a3\sounds_f\weapons\hits\metal_plate_1.wss",
        "a3\sounds_f\weapons\hits\metal_plate_2.wss",
        "a3\sounds_f\weapons\hits\metal_plate_3.wss",
        "a3\sounds_f\weapons\hits\metal_plate_4.wss",
        "a3\sounds_f\weapons\hits\metal_plate_5.wss",
        "a3\sounds_f\weapons\hits\metal_plate_6.wss",
        "a3\sounds_f\weapons\hits\metal_plate_7.wss",
        "a3\sounds_f\weapons\hits\metal_plate_8.wss"
    ];
    for "_i" from 1 to 3 do {
        private _sound = selectRandom _sounds;
        playSoundUI [_sound, 2];
    };
    uiSleep 0.1;
    for "_i" from 1 to 3 do {
        private _sound = selectRandom _sounds;
        playSoundUI [_sound, 2];
    };
    uiSleep 0.1;
    for "_i" from 1 to 3 do {
        private _sound = selectRandom _sounds;
        playSoundUI [_sound, 2];
    };
};