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

if (typeof _vehicle == "B_Truck_01_flatbed_F") exitWith {
    [false, "Flatbeds cannot be paradropped."];
};

[true, ""];