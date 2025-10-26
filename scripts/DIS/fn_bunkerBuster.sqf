#include "includes.inc"
params ["_projectile", "_position"];

private _bombClass = typeof _projectile;
private _penetrator = createVehicle [_bombClass, _position, [], 0, "NONE"];
_penetrator enableSimulation false;

private _inDestroyerArea = {
    _position inArea _x
} count ["marker_USS Liberty_outline", "marker_USS Freedom_outline", "marker_USS Independence_outline"] > 0;
if (_inDestroyerArea) then {
    _position set [2, 9.5];
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

uiSleep 5;

_penetrator enableSimulation true;
triggerAmmo _penetrator;

private _nearDestroyables = (_position nearObjects 30) select {
    _x getVariable ["WL2_canDemolish", false];
};
{
    [_x, 7] call WL2_fnc_demolishStep;
} forEach _nearDestroyables;