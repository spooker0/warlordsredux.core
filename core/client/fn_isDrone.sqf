#include "includes.inc"
params ["_asset"];

if (unitIsUAV _asset) exitWith { true };
private _assetActualType = _asset getVariable ["WL2_orderedClass", typeOf _asset];
WL_ASSET(_assetActualType, "drone", 0) > 0;