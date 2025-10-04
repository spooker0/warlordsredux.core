#include "includes.inc"
params ["_asset"];

if !(local _asset) exitWith {};
_asset setVariable ["WL2_ecmCharges", -100];

private _assetActualType = _asset getVariable ["WL2_orderedClass", typeOf _asset];
private _apsType = WL_ASSET(_assetActualType, "aps", -1);
if (_apsType <= 0) exitWith {};

_asset setVariable ["apsAmmo", _asset call APS_fnc_getMaxAmmo, true];