#include "includes.inc"
params ["_asset", ["_assetType", ""]];

if (_assetType == "") then {
    _assetType = typeOf _asset;
};
private _assetActualType = _asset getVariable ["WL2_orderedClass", _assetType];
WL_ASSET(_assetActualType, "name", getText (configFile >> "CfgVehicles" >> _assetActualType >> "displayName"));