#include "includes.inc"
params ["_target", "_caller"];

if (!alive _target) exitWith {
    false
};

private _hasAccess = ([_target, _caller, "full"] call WL2_fnc_accessControl) # 0;
if (!_hasAccess) exitWith {
    false
};

private _nearbyRepair = (_target nearEntities ["All", WL_MAINTENANCE_RADIUS]) select {
    alive _x
} select {
    getNumber (configFile >> "CfgVehicles" >> typeOf _x >> "transportRepair") > 0
} select {
    ([_x, _caller, "cargo"] call WL2_fnc_accessControl) # 0
};

count _nearbyRepair > 0;