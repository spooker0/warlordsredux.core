#include "includes.inc"
if (isNull WL_TARGET_FRIENDLY) then {
    [false, localize "STR_A3_WL_no_conflict"];
} else {
    [true, ""];
};