#include "..\..\warlords_constants.inc"

params [["_requireGround", true]];

private _vehicle = vehicle player;
private _isInVehicle = _vehicle != player;
if (!_isInVehicle) exitWith {
    [false, "You must be in a vehicle."];
};

private _isGroundVehicle = _vehicle isKindOf "LandVehicle";
if (_requireGround && !_isGroundVehicle) exitWith {
    [false, "You must be in a ground vehicle."];
};

private _isInDriverSeat = (driver _vehicle) == player;
if (!_isInDriverSeat) exitWith {
    [false, "You must be in the driver seat."];
};

private _isAttached = !isNull attachedTo _vehicle;
private _attachedObject = "";
if (_isAttached) then {
    _attachedObject = [attachedTo _vehicle] call WL2_fnc_getAssetTypeName;
};
private _hasAttachment = count attachedObjects _vehicle > 0;
if (_hasAttachment) then {
    _attachedObject = [attachedObjects _vehicle # 0] call WL2_fnc_getAssetTypeName;
};

if (_attachedObject != "") exitWith {
    [false, format ["Your vehicle is attached to: %1", _attachedObject]];
};

[true, ""];