#include "includes.inc"
params ["_asset", "_radius"];
if (isDedicated) exitWith {};

private _iteration = 0;
while { alive _asset } do {
	[_asset, _radius, _iteration] call WL2_fnc_scanner;
	uiSleep 2;
	_iteration = _iteration + 1;
};