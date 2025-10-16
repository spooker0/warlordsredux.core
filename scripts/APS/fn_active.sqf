#include "includes.inc"
params ["_asset"];

private _activated = _asset getVariable ["WL2_apsActivated", false];
if (!_activated) exitWith {
	false;
};
_asset getVariable ["apsAmmo", 0] > 0;