#include "includes.inc"
private _assetLimit = WL_MAX_ASSETS;

private _ownedVehiclesVar = format ["BIS_WL_ownedVehicles_%1", getPlayerUID player];
private _ownedVehicles = missionNamespace getVariable [_ownedVehiclesVar, []];

if (count _ownedVehicles >= _assetLimit) then {
    [false, localize "STR_A3_WL_popup_asset_limit_reached"]
} else {
    [true, ""]
};
