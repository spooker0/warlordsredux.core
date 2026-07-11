#include "includes.inc"
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

private _disableParadrop = WL_UNIT(_vehicle, "disableParadrop", 0);
if (_disableParadrop > 0) exitWith {
    [false, "This vehicle cannot be paradropped."];
};

[true, ""];