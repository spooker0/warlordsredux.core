#include "includes.inc"
params ["_class", "_position", "_direction", "_uid", "_objsToIgnore"];

private _simulatedObject = [_class, _position, 0, true, false, true] call BIS_fnc_createSimpleObject;
_simulatedObject setVectorDirAndUp _direction;
_simulatedObject setPosWorld _position;

private _circleA = boundingBoxReal [_simulatedObject, "FireGeometry"];
private _radiusA = _circleA select 2;

private _BUFFER = 1;
private _nearbyEntities = (_simulatedObject nearEntities 30) select {
    private _circleB = boundingBoxReal [_x, "FireGeometry"];
    private _radiusB = _circleB select 2;
    _x distance _simulatedObject < (_radiusA + _radiusB + _BUFFER)
} select {
    private _assetOwner = _x getVariable ["BIS_WL_ownerAsset", "notAsset"];
    _assetOwner != "notAsset"
} select {
    !(_x in _objsToIgnore)
} select {
    !(_x isKindOf "Man")
} select {
    !(_x isKindOf "Building")
} select {
    _uid != (_x getVariable ["BIS_WL_ownerAsset", "123"])
};

deleteVehicle _simulatedObject;

_nearbyEntities