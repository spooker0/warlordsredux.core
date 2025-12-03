#include "includes.inc"
params ["_sector"];

private _spawnPos = [];
private _dir = 0;

if (_sector getVariable ["WL2_isAircraftCarrier", false]) then {
	private _carrierSettings = _sector getVariable ["WL2_aircraftCarrierAir", []];
	{
		private _potentialSpawnPos = _x # 0;
		private _potentialSpawnDir = _x # 1;

		private _potentialSpawnPosASL = ATLtoASL _potentialSpawnPos;

		private _vehiclesNear = nearestObjects [_potentialSpawnPosASL, ["AllVehicles", "ReammoBox_F"], 20, true];
		private _collisionObjects = _vehiclesNear select {
			!(_x isKindOf "Man")
		};
		if (count _collisionObjects == 0) then {
			_spawnPos = _potentialSpawnPos;
			_dir = _potentialSpawnDir;
			break;
		};
	} forEach (_carrierSettings call BIS_fnc_arrayShuffle);
} else {
	private _taxiNodes = _sector getVariable ["BIS_WL_runwaySpawnPosArr", []];
	private _taxiNodesCnt = count _taxiNodes;
	private _checks = 0;
	while { count _spawnPos == 0 && _checks < 100 } do {
		_checks = _checks + 1;
		private _i = (floor random _taxiNodesCnt) max 1;
		private _pointB = _taxiNodes # _i;
		private _pointA = _taxiNodes # (_i - 1);
		_dir = _pointA getDir _pointB;
		private _pos = [_pointA, random (_pointA distance2D _pointB), _dir] call BIS_fnc_relPos;
		private _vehiclesNear = nearestObjects [_pos, ["AllVehicles", "ReammoBox_F"], 20, true];
		private _collisionObjects = _vehiclesNear select {
			!(_x isKindOf "Man")
		};
		if (count _collisionObjects == 0) then {
			_spawnPos = _pos;
			break;
		};
		uiSleep 0.001;
	};
};

[_spawnPos, _dir];