#include "includes.inc"
params ["_category", "_cost"];

if (_cost < 10000) exitWith {
    [true, ""]
};

if (!(_category in ["Fixed Wing", "Rotary Wing", "Remote Control"])) exitWith {
    [true, ""]
};

#if WL_AIR_POP_LIMIT

if (count allPlayers < 14) exitWith {
    [false, localize "STR_WL_airSpawnPlayerCountLow"];
};

#endif

[true, ""];
