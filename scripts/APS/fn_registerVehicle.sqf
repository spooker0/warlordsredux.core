#include "includes.inc"
params ["_asset"];

private _assetActualType = _asset getVariable ["WL2_orderedClass", typeOf _asset];
private _apsType = WL_ASSET(_assetActualType, "aps", -1);
private _ammo = switch (_apsType) do {
	case 4: { 0 };
	case 3: { 6 };
	case 2: { 4 };
	case 1: { 2 };
	default { -1 };
};

_asset setVariable ["apsType", _apsType - 1, true];
if (_ammo > 0) then {
	_asset setVariable ["apsAmmo", _ammo, true];
};