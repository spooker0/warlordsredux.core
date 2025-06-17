#include "includes.inc"
params ["_asset"];

private _assetActualType = _asset getVariable ["WL2_orderedClass", typeOf _asset];
private _apsType = WL_ASSET(_assetActualType, "aps", -1);
if (_apsType == 4) then {		// is dazzler
	private _isDazzlerActivated = _asset getVariable ["WL2_dazzlerActivated", false];
	private _hasCharges = [_asset] call APS_fnc_hasCharges;
	_isDazzlerActivated && _hasCharges
} else {
	[_asset] call APS_fnc_hasCharges;
};