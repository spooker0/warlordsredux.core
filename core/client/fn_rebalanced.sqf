#include "includes.inc"
params ["_rebalancedPlayer", "_message"];
if (player != _rebalancedPlayer) exitWith {};
[_message, "Rebalanced"] call WL2_fnc_exitToLobby;