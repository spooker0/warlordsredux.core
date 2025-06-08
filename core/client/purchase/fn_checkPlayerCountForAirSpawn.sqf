#include "includes.inc"
params ["_category", "_cost"];

if (_cost < 5000) exitWith {
    [true, ""]
};

if !(_category in ["Fixed Wing", "Rotary Wing", "Remote Control"]) exitWith {
    [true, ""]
};

#if WL_AIR_POP_LIMIT
if ((playersNumber west) <= 7 && (playersNumber east) <= 7) exitWith {
    [false, "Player count is too low to deploy heavily armed aerial assets."];
};
#endif

[true, ""];