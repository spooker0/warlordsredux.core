#include "includes.inc"

private _storedIsOrdering = player getVariable ["BIS_WL_isOrdering", false];
if (_storedIsOrdering) then {
    [false, "Another order is in progress!"];
} else {
    [true, ""];
};
