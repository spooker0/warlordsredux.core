#include "includes.inc"
params ["_asset"];

private _assetActualType = _asset getVariable ["WL2_orderedClass", typeOf _asset];

private _isImmobile = WL_ASSET(_assetActualType, "immobile", 0) > 0;
if (_isImmobile) exitWith { false };

if (unitIsUAV _asset) exitWith { true };
WL_ASSET(_assetActualType, "drone", 0) > 0;