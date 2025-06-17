#include "includes.inc"
params ["_asset"];

private _assetActualType = _asset getVariable ["WL2_orderedClass", typeOf _asset];
private _apsType = WL_ASSET(_assetActualType, "aps", -1);
switch (_apsType) do {
	case 4: { 25 };
	case 3: { 6 };
	case 2: { 4 };
	case 1: { 2 };
	default { -1 };
};