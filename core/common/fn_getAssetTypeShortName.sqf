#include "includes.inc"
params ["_asset"];
private _cachedName = _asset getVariable ["WL2_assetTypeShortName", ""];
if (_cachedName != "") exitWith {
    _cachedName;
};

[_asset] call WL2_fnc_getAssetTypeName;