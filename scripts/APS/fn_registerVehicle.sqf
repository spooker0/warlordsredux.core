#include "includes.inc"
params ["_asset"];
private _ammo = [_asset] call APS_fnc_getMaxAmmo;

private _apsType = WL_UNIT(_asset, "aps", 0);
_asset setVariable ["APS_apsType", _apsType, true];
if (_ammo > 0) then {
	_asset setVariable ["apsAmmo", _ammo, true];
};