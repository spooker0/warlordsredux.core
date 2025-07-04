#include "includes.inc"
params ["_target", "_caller"];

private _isAlive = alive _target;
private _stopped = speed _target < 1;
private _hasAccess = ([_target, _caller, "full"] call WL2_fnc_accessControl) # 0;
private _nearbyRefuel = (_target nearEntities ["All", WL_MAINTENANCE_RADIUS]) select {
    alive _x &&
    getNumber (configFile >> "CfgVehicles" >> typeOf _x >> "transportFuel") > 0 &&
    ([_x, _caller, "cargo"] call WL2_fnc_accessControl) # 0
};

_isAlive && _stopped && _hasAccess && count _nearbyRefuel > 0;