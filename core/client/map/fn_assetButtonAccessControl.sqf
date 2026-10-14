#include "includes.inc"
params ["_accessControl"];

([_accessControl] call WL2_fnc_getVehicleLockStatus) params ["_lockColor", "_lockLabel"];
if (_lockLabel == "") exitWith { "" };

format ["<t color='%1'>%2</t>", _lockColor, _lockLabel];