#include "includes.inc"
params ["_asset"];

if (!alive _asset) exitWith { false };
if (cameraOn != _asset) exitWith { false };
if (speed _asset > 0.5) exitWith { false };

private _inCarrierSectors = BIS_WL_allSectors select {
    _x getVariable ["WL2_isAircraftCarrier", false]
} select {
    _asset inArea (_x getVariable "objectAreaComplete")
};
private _isInCarrierSector = count _inCarrierSectors > 0;
if (_isInCarrierSector) exitWith { true };

private _allUnits = (BIS_WL_westOwnedVehicles + BIS_WL_eastOwnedVehicles + BIS_WL_guerOwnedVehicles) select {
    WL_ISUP(_x)
};
private _unitsNearby = _allUnits inAreaArray [getPosASL _asset, 100, 100, 0, false];
private _railsNearby = _unitsNearby select {
    typeof _x == "Land_CraneRail_01_F"
};

count _railsNearby > 0