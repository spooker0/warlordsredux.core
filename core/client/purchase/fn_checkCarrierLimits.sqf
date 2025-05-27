#include "..\..\warlords_constants.inc"

params ["_sector", "_category"];

private _isCarrierSector = _sector getVariable ["WL2_isAircraftCarrier", false];
if (_isCarrierSector && _category == "Heavy Vehicles") exitWith {
    [false, "Heavy vehicles unavailable on aircraft carrier."];
};
[true, ""];