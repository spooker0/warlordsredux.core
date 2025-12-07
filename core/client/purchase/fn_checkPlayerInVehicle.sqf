#include "includes.inc"
params [["_requirements", []]];

if (vehicle player == player) exitWith {
    [true, ""];
};
[false, localize "STR_A3_WL_fasttravel_restr3"];