#include "includes.inc"
params ["_asset", ["_assetType", ""]];
private _cachedName = _asset getVariable ["WL2_assetTypeName", ""];
if (_cachedName != "") exitWith {
    _cachedName;
};

private _assetActualType = if (_assetType == "") then {
    _asset getVariable ["WL2_orderedClass", typeOf _asset];
} else {
    _assetType
};

private _name = WL_ASSET(_assetActualType, "name", "");
if (_name != "") then {
    // cache only if the name was defined
    _asset setVariable ["WL2_assetTypeName", _name];
} else {
    _name = getText (configFile >> "CfgVehicles" >> _assetActualType >> "displayName");
};

_name