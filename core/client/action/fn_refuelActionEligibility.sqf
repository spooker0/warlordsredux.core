#include "..\..\warlords_constants.inc"

params ["_target", "_caller"];

private _isAlive = alive _target;
private _stopped = speed _target < 1;
private _hasAccess = ([_target, _caller, "full"] call WL2_fnc_accessControl) # 0;
private _isInVehicle = cursorObject == _target;
private _nearbyRefuel = (_target nearEntities ["All", WL_MAINTENANCE_RADIUS]) select {
    alive _x &&
    getNumber (configFile >> "CfgVehicles" >> typeOf _x >> "transportFuel") > 0 &&
    ([_x, _caller, "cargo"] call WL2_fnc_accessControl) # 0
};
private _isBlocked = _target getVariable ["WL2_refuelBlocked", 0] > serverTime;

_isAlive && _stopped && _hasAccess && _isInVehicle && count _nearbyRefuel > 0 && !_isBlocked;