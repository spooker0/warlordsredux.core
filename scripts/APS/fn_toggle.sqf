#include "includes.inc"
params ["_asset"];
if (_asset getVariable ["apsType", -1] <= -1) exitWith {};
private _apsActive = _asset getVariable ["WL2_apsActivated", false];
if (_apsActive) then {
    _asset setVariable ["WL2_apsActivated", false, true];
    playSoundUI ["a3\sounds_f_bootcamp\sfx\vr\simulation_fatal.wss"];
} else {
    _asset setVariable ["WL2_apsActivated", true, true];
    playSoundUI ["a3\sounds_f_bootcamp\sfx\vr\simulation_restart.wss"];
};