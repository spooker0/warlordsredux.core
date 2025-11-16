#include "includes.inc"
params ["_side", ["_localized", true]];

if (_localized) then {
    [localize "STR_west", localize "STR_east", localize "STR_guerrila"] # (BIS_WL_sidesArray find _side)
} else {
    ["BLUFOR", "OPFOR", "INDFOR"] # (BIS_WL_sidesArray find _side)
};