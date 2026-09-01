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

private _isWeaponDeployed = _vehicle getVariable ["WL2_isWeaponDeployed", false];
if (_isWeaponDeployed) exitWith {
    [false, "This vehicle's weapon is currently deployed."];
};

private _lastDamageTime = _vehicle getEntityInfo 5;
if (damage _vehicle > 0 && _lastDamageTime > 0 && _lastDamageTime < WL_COOLDOWN_JETRTB_DMG) exitWith {
    private _cooldownText = [WL_COOLDOWN_JETRTB_DMG - _lastDamageTime, "MM:SS"] call BIS_fnc_secondsToString;
    [false, format ["Vehicle damaged too recently to paradrop: %1", _cooldownText]];
};

[true, ""];