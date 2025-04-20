#include "..\..\warlords_constants.inc"

private _vehicles = (nearestObjects [player, [], 20, true]) select {
    alive _x;
} select {
    (_x getVariable ["WL2_accessControl", -2]) != -2;
} select {
    !(_x getVariable ["WL2_transporting", false]);
} select {
    !(_x isKindOf "Man");
} select {
    private _access = [_x, player, "driver"] call WL2_fnc_accessControl;
    _access # 0;
};

if (count _vehicles == 0) exitWith {
    [false, "No valid, accessible vehicles within 20 meters."];
};

[true, ""];