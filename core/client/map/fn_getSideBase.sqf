#include "includes.inc"
params ["_side"];

if (_side == west) exitWith {
	WL2_base1;
};

if (_side == east) exitWith {
	WL2_base2;
};

private _independentSectors = BIS_WL_allSectors select {
	(_x getVariable ["BIS_WL_owner", independent]) == independent
};
selectRandom _independentSectors;