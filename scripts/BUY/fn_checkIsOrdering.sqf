#include "includes.inc"

private _storedIsOrdering = player getVariable ["BIS_WL_isOrdering", false];
if (_storedIsOrdering) then {
    [false, localize "STR_WL_orderInProgress"];
} else {
    [true, ""];
};
