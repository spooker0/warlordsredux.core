#include "includes.inc"
params ["_target", "_caller"];

if (!alive _target) exitWith {
    false
};

if (speed _target > 1) exitWith {
    false
};

private _hasAccess = ([_target, _caller, "full"] call WL2_fnc_accessControl) # 0;
if (!_hasAccess) exitWith {
    false
};

private _nearbyRefuel = (BIS_WL_westOwnedVehicles + BIS_WL_eastOwnedVehicles + BIS_WL_guerOwnedVehicles) select { alive _x } select {
    _x distance2D _target < WL_MAINTENANCE_RADIUS
} select {
    WL_UNIT(_x, "hasRefuel", 0) > 0
};

count _nearbyRefuel > 0;