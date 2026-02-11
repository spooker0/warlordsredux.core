#include "includes.inc"
if (count allPlayers < 2) then {
    [false, localize "STR_WL_noAlliedPlayers"]
} else {
    [true, ""]
};