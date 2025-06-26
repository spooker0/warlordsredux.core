#include "includes.inc"
params ["_class"];
if (_class isKindOf "Man") exitWith {
    [true, ""];
};

private _ownedVehiclesVar = format ["BIS_WL_ownedVehicles_%1", getPlayerUID player];
private _ownedVehicles = missionNamespace getVariable [_ownedVehiclesVar, []];
_ownedVehicles = _ownedVehicles select { alive _x };
private _limitedVehicles = [];
private _typeLimit = 0;
if (_class isKindOf "Building") then {
    _limitedVehicles = _ownedVehicles select { _x isKindOf "Building" };
    _typeLimit = WL_MAX_BUILDINGS;
} else {
    _limitedVehicles = _ownedVehicles select { !(_x isKindOf "Building") };
    _typeLimit = WL_MAX_ASSETS;
};

if (count _limitedVehicles >= _typeLimit) exitWith {
    [false, localize "STR_A3_WL_popup_asset_limit_reached"];
};

[true, ""];