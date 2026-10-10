#include "includes.inc"
params ["_asset"];

private _capacity = WL_UNIT(_asset, "flareBursts", 0);
if (_capacity <= 0) exitWith {};

_asset setVariable ["DIS_flareBursts", _capacity, true];
_asset setVariable ["DIS_flareReadyAt", 0];