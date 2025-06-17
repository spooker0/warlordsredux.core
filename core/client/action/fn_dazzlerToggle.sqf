#include "includes.inc"
params ["_asset"];

if ([_asset] call APS_fnc_active) then {
    _asset setVariable ["WL2_dazzlerActivated", false, true];
    playSoundUI ["a3\sounds_f_bootcamp\sfx\vr\simulation_fatal.wss"];
} else {
    _asset setVariable ["WL2_dazzlerActivated", true, true];
    playSoundUI ["a3\sounds_f_bootcamp\sfx\vr\simulation_restart.wss"];
};