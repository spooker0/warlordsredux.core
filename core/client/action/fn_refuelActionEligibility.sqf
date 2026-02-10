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

private _nearbyRefuel = (_target nearEntities ["All", WL_MAINTENANCE_RADIUS]) select {
    alive _x
} select {
    WL_UNIT(_x, "hasRefuel", 0) > 0
} select {
    ([_x, _caller, "cargo"] call WL2_fnc_accessControl) # 0
};

count _nearbyRefuel > 0;