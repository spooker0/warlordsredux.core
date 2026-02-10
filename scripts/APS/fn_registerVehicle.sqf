#include "includes.inc"
params ["_asset"];
private _ammo = [_asset] call APS_fnc_getMaxAmmo;

private _apsType = WL_UNIT(_asset, "aps", -1);
_asset setVariable ["apsType", _apsType - 1, true];
if (_ammo > 0) then {
	_asset setVariable ["apsAmmo", _ammo, true];
};