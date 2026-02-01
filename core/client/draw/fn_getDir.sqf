#include "includes.inc"
params ["_unit"];

if (WL_ISDOWN(_unit)) exitWith {
    0;
};
if (_unit getVariable ["WL_ewNetActive", false]) exitWith {
	0;
};

getDirVisual _unit;