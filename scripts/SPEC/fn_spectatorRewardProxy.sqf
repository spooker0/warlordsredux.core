#include "includes.inc"
params ["_reward", "_reason"];

[objNull, _reward, format ["SPECTATE: %1", _reason], WL_COLOR_KILL] call WL2_fnc_killRewardClient;