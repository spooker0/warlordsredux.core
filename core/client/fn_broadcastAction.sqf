#include "includes.inc"
params ["_message"];
if (isDedicated) exitWith {};
[_message] call WL2_fnc_smoothText;