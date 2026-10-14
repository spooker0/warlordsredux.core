#include "includes.inc"
params ["_asset"];

private _flareConfig = WL_UNIT(_asset, "flares", []);
if (count _flareConfig == 0) exitWith {};

private _capacity = _flareConfig # 0;
if (_capacity <= 0) exitWith {};

_asset setVariable ["DIS_flareBursts", _capacity, true];
_asset setVariable ["DIS_flareReadyAt", 0];