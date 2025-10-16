#include "includes.inc"
params ["_target", "_caller"];

if (!alive _target) exitWith {
    false
};

if (vehicle _caller != _target) exitWith {
    false
};

true;