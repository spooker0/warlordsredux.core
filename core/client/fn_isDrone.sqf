#include "includes.inc"
params ["_asset"];

private _assetActualType = WL_ASSET_TYPE(_asset);

if (unitIsUAV _asset) exitWith { true };
WL_ASSET(_assetActualType, "drone", 0) > 0;