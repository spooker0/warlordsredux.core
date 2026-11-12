#include "includes.inc"
params ["_sector", "_category"];

private _isCarrierSector = _sector getVariable ["WL2_isAircraftCarrier", false];
if (_isCarrierSector && _category == "Heavy Vehicles") exitWith {
    [false, localize "STR_WL_heavyUnavailableOnCarrier"];
};

[true, ""];
