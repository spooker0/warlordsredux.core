#include "includes.inc"
params ["_projectileClass", "_position", "_dirAndUp", "_bunkerBusterSteps", ["_ignoreHeight", false]];

private _penetrator = createVehicle [_projectileClass, _position, [], 0, "NONE"];
_penetrator setVariable ["APS_ammoOverride", "BunkerBuster"];
_penetrator setVectorDirAndUp _dirAndUp;
_penetrator enableSimulation false;

private _nearDestroyables = (nearestObjects [_position, [], 100, true]) select {
    private _distanceLimit = if (_x isKindOf "StaticShip") then { 100 } else { 15 };
    _x distance2D _position < _distanceLimit && _x getVariable ["WL2_canDemolish", false];
} select {
    private _assetActualType = _x getVariable ["WL2_orderedClass", typeOf _x];
    WL_ASSET(_assetActualType, "obstacle", 0) == 0;
};

if (_ignoreHeight) then {
    _penetrator setPosASL _position;
} else {
    private _inDestroyerArea = {
        _position inArea _x
    } count WL_DESTROYER_OUTLINES > 0;
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
            _position set [2, 0.7];
            _penetrator setPosATL _position;
        };
    };
};

[_penetrator, [player, player]] remoteExec ["setShotParents", 2];

private _startTime = serverTime;
waitUntil {
    uiSleep 0.001;
    private _shotParents = getShotParents _penetrator;
    !isNull (_shotParents # 0) || serverTime - _startTime > 5
};

_penetrator enableSimulation true;
triggerAmmo _penetrator;

{
    [_x, _bunkerBusterSteps] call WL2_fnc_demolishStep;
} forEach _nearDestroyables;