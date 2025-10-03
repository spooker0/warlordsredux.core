#include "includes.inc"
params ["_sector"];

private _spawnPositionCache = _sector getVariable ["WL2_spawnPositionsCache", []];

if (count _spawnPositionCache > 0) exitWith {
    _spawnPositionCache;
};

private _isCarrier = _sector getVariable ["WL2_isAircraftCarrier", false];
if (_isCarrier) exitWith {
    private _spawnLocations = _sector getVariable ["WL2_aircraftCarrierInf", []];
	private _carrierSpawns = if (count _spawnLocations == 0) then {
		[getPosATL _sector];
	} else {
		_spawnLocations + _spawnLocations + _spawnLocations;
	};

    _sector setVariable ["WL2_spawnPositionsCache", _carrierSpawns];
    _carrierSpawns;
};

private _objectArea = _sector getVariable ["objectAreaComplete", []];

private _allPositions = [_objectArea] call WL2_fnc_findSpawnsInArea;

if (count _allPositions == 0) then {
    _allPositions = [getPosATL _sector];
};

_sector setVariable ["WL2_spawnPositionsCache", _allPositions];
_allPositions;