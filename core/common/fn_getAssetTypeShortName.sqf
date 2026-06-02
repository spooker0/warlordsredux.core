#include "includes.inc"
params ["_asset", ["_assetType", ""]];
private _cachedName = _asset getVariable ["WL2_assetTypeShortName", ""];
if (_cachedName != "") exitWith {
    _cachedName;
};

private _assetActualType = if (isNull _asset) then {
    _assetType
} else {
    _asset getVariable ["WL2_orderedClass", typeOf _asset];
};
private _shortName = WL_ASSET(_assetActualType, "nameShort", "");
if (_shortName == "") then {
    _shortName = [_asset, _assetActualType] call WL2_fnc_getAssetTypeName;
};
_asset setVariable ["WL2_assetTypeShortName", _shortName];
_shortName