#include "includes.inc"
params ["_reward", "_reason"];

[objNull, _reward, format ["SPECTATE: %1", _reason], "#de0808"] call WL2_fnc_killRewardClient;