#include "includes.inc"
params ["_projectileClass", "_position", ["_bunkerBusterSteps", 7], ["_delay", 5]];

private _penetrator = createVehicle [_projectileClass, _position, [], 0, "NONE"];
_penetrator enableSimulation false;

private _nearDestroyables = (nearestObjects [_position, [], 100, true]) select {
    private _distanceLimit = if (_x isKindOf "StaticShip") then { 100 } else { 30 };
    _x distance _position < _distanceLimit && _x getVariable ["WL2_canDemolish", false];
};

private _inDestroyerArea = {
    _position inArea _x
} count ["marker_USS Liberty_outline", "marker_USS Freedom_outline", "marker_USS Independence_outline"] > 0;
if (_inDestroyerArea) then {
    _position set [2, 9.8];
    _penetrator setPosASL _position;
} else {
    private _inCarrierSector = {
        _position inArea (_x getVariable "objectAreaComplete") && _x getVariable ["WL2_isAircraftCarrier", false];
    } count BIS_WL_allSectors > 0;
    if (_inCarrierSector) then {
        _position set [2, 24.5];
        _penetrator setPosASL _position;
    } else {
        _position set [2, 0.5];
        _penetrator setPosATL _position;
    };
};

[_penetrator, [player, player]] remoteExec ["setShotParents", 2];

uiSleep _delay;

_penetrator enableSimulation true;
triggerAmmo _penetrator;

{
    [_x, _bunkerBusterSteps] call WL2_fnc_demolishStep;
} forEach _nearDestroyables;