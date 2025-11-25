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
    private _assetActualType = _x getVariable ["WL2_orderedClass", typeOf _x];
    WL_ASSET(_assetActualType, "hasRefuel", 0) > 0
} select {
    ([_x, _caller, "cargo"] call WL2_fnc_accessControl) # 0
};

count _nearbyRefuel > 0;