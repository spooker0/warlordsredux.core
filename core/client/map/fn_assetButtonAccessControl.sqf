#include "includes.inc"
params ["_accessControl"];

(_accessControl call WL2_fnc_getVehicleLockStatus) params ["_lockColor", "_lockLabel"];

private _lockColorClass = [
    "green", "green", "green",
    "cyan", "cyan", "cyan",
    "red",
    "red"
] select _accessControl;

private _lockText = format ["<span class='%1'>%2</span>", _lockColorClass, _lockLabel];
_lockText;