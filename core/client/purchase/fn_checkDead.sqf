#include "includes.inc"
if (WL_ISDOWN(player)) then {
    [false, localize "STR_A3_WL_fasttravel_restr6"];
} else {
    [true, ""];
};