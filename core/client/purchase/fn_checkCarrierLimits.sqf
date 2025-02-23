#include "..\..\warlords_constants.inc"

params ["_sector", "_category"];

private _isCarrierSector = count (_sector getVariable ["WL_aircraftCarrier", []]) > 0;
if (_isCarrierSector && _category == "Heavy Vehicles") exitWith {
    [false, "Heavy vehicles unavailable on aircraft carrier."];
};
if (_isCarrierSector && _category == "Infantry") exitWith {
    [false, "AI spawning disabled on aircraft carrier."];
};
[true, ""];