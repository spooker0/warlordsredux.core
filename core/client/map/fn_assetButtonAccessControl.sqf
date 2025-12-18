#include "includes.inc"
params ["_accessControl"];

(_accessControl call WL2_fnc_getVehicleLockStatus) params ["_lockColor", "_lockLabel"];

private _lockColorHex = [
    "#00ff00", "#00ff00", "#00ff00",
    "#00ffff", "#00ffff", "#00ffff",
    "#ff0000",
    "#ff0000"
] select _accessControl;

private _lockText = format ["<t color='%1'>%2</t>", _lockColorHex, _lockLabel];
_lockText;