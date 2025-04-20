params ["_sender", "_pos", "_orderedClass"];

if !(isServer) exitWith {};

private _class = missionNamespace getVariable ["WL2_spawnClass", createHashMap] getOrDefault [_orderedClass, _orderedClass];

private _position = _pos vectorAdd [0,0,3];
private _asset = createVehicle [_class, _position, [], 0, "CAN_COLLIDE"];
_asset setDir (getDir _sender);
[_asset, _sender, _orderedClass] call WL2_fnc_processOrder;

if (_sender distance2D _asset < 100) then {
    _sender setPosASL _position;
    _sender moveInAny _asset;
};