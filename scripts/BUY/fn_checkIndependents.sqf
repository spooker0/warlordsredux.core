#include "includes.inc"

if (BIS_WL_playerSide == independent) then {
    [false, localize "STR_WL_notAvailableForIndependents"];
} else {
    [true, ""];
};
