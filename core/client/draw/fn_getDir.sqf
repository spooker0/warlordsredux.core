#include "includes.inc"
params ["_unit"];

if (!alive _unit || lifeState _unit == "INCAPACITATED") exitWith {
    0;
};
if (_unit getVariable ["WL_ewNetActive", false]) exitWith {
	0;
};

getDirVisual _unit;