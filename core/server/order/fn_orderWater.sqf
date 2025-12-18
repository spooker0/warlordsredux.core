#include "includes.inc"
params ["_sender", "_pos", "_orderedClass"];

if !(isServer) exitWith {};

private _class = WL_ASSET(_orderedClass, "spawn", _orderedClass);

private _position = _pos vectorAdd [0, 0, 1];
private _asset = createVehicle [_class, _position, [], 0, "CAN_COLLIDE"];
_asset setDir (getDir _sender);
_asset setPosASL _position;

[_asset, _sender, _orderedClass] call WL2_fnc_processOrder;

private _drone = WL_ASSET(_orderedClass, "drone", 0);
if (_drone == 0) then {
    [_sender, _asset] remoteExec ["moveInDriver", _sender];
};