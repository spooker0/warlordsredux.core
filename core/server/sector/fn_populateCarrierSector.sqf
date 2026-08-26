#include "includes.inc"
params ["_sector"];

private _spawnLocations = _sector getVariable ["WL2_aircraftCarrierInf", []];

private _spawnCarrierVehicle = {
	params ["_vehicleType", "_spawnPos", "_direction"];

	private _vehicle = [objNull, _spawnPos, _vehicleType, _direction, false, false] call WL2_fnc_orderGround;
	_vehicleUnits pushBack _vehicle;
    _vehicle setAutonomous true;
};

private _vehicleUnits = [];
private _presetVehicles = _sector getVariable ["WL2_vehiclesToSpawn", []];
{
    _x params ["_vehicleType", "_spawnPos", "_direction"];
    private _vehicle = [objNull, _spawnPos, _vehicleType, _direction, false, false] call WL2_fnc_orderGround;
	_vehicleUnits pushBack _vehicle;
    _vehicle setAutonomous true;
    _vehicle setVariable ["WL2_sectorDefender", _sector];
} forEach _presetVehicles;

{
    private _location = +_x;
    if (_location # 2 < 23) then {
        continue;
    };
    _location set [2, _location # 2 + 0.5];
    private _vehicle = [objNull, _location, "Land_Pallet_MilBoxes_F", random 360, true, false] call WL2_fnc_orderGround;
	_vehicleUnits pushBack _vehicle;
    _vehicle setVariable ["WL2_sectorDefender", _sector];
} forEach _spawnLocations;

private _ownedVehicles = missionNamespace getVariable ["BIS_WL_ownedVehicles_server", []];
_ownedVehicles append _vehicleUnits;
missionNamespace setVariable ["BIS_WL_ownedVehicles_server", _ownedVehicles];