#include "..\..\warlords_constants.inc"

private _hasCarrierSector = (BIS_WL_sectorsArray # 0) select {
    _x getVariable ["WL2_isAircraftCarrier", false]
};
if (count _hasCarrierSector > 0) then {
    [true, ""]
} else {
    [false, "No aircraft carriers available."];
};