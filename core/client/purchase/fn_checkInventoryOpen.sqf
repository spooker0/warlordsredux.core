#include "includes.inc"
if !(isNull (findDisplay 602)) then {
    [false, localize "STR_WL_closeInventory"];
} else {
    [true, ""];
};