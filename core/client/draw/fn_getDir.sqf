#include "includes.inc"
params ["_unit"];

if (!alive _unit || lifeState _unit == "INCAPACITATED") then {
    0;
} else {
    getDirVisual _unit;
};