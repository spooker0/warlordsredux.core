#include "includes.inc"
params ["_asset"];

private _assetActualType = _asset getVariable ["WL2_orderedClass", typeOf _asset];
private _apsType = WL_ASSET(_assetActualType, "aps", -1);
if (_apsType == 4) then {		// is dazzler
	private _isDazzlerActivated = _asset getVariable ["BIS_WL_dazzlerActivated", false];
	private _isEngineOn = isEngineOn _asset;
	private _isEngineHealthy = (_asset getHitPointDamage "hitEngine") < 0.5;
	_isDazzlerActivated && _isEngineOn && _isEngineHealthy
} else {
	[_asset] call APS_fnc_hasCharges;
};