#include "includes.inc"
params ["_asset"];

if !(local _asset) exitWith {};

private _apsType = WL_UNIT(_asset, "aps", 0);
if (_apsType <= 0) exitWith {};

_asset setVariable ["apsAmmo", _asset call APS_fnc_getMaxAmmo, true];