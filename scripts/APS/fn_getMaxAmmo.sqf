#include "includes.inc"
params ["_asset"];

private _apsType = WL_UNIT(_asset, "aps", 0);
switch (_apsType) do {
	case 5: { 10 };
	case 4: { 25 };
	case 3: { 6 };
	case 2: { 4 };
	case 1: { 2 };
	default { -1 };
};