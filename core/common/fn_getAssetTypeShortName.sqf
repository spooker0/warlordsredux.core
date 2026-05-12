#include "includes.inc"
params ["_asset"];
private _cachedName = _asset getVariable ["WL2_assetTypeShortName", ""];
if (_cachedName != "") exitWith {
    _cachedName;
};

private _assetActualType = _asset getVariable ["WL2_orderedClass", typeOf _asset];
private _shortName = WL_ASSET(_assetActualType, "nameShort", "");
if (_shortName == "") then {
    _shortName = [_asset] call WL2_fnc_getAssetTypeName;
};
_asset setVariable ["WL2_assetTypeShortName", _shortName];
_shortName