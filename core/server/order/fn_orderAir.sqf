params ["_sender", "_pos", "_orderedClass", "_cost"];

if !(isServer) exitWith {};
private _class = missionNamespace getVariable ["WL2_spawnClass", createHashMap] getOrDefault [_orderedClass, _orderedClass];

private _owner = owner _sender;;

private _spawnPos = [];
private _dir = 0;

private _sector = (_pos nearObjects ["Logic", 10]) select { _x in BIS_WL_allSectors } select 0;

if (_sector getVariable ["WL2_isAircraftCarrier", false]) then {
	private _carrierSettings = _sector getVariable ["WL2_aircraftCarrierAir", []];
	{
		private _potentialSpawnPos = _x # 0;
		private _potentialSpawnDir = _x # 1;

		private _potentialSpawnPosASL = ATLtoASL _potentialSpawnPos;
		private _collisionObjects = (_potentialSpawnPosASL nearObjects ["AllVehicles", 20]) select {
			!(_x isKindOf "Man")
		};
		if (count _collisionObjects == 0) then {
			_spawnPos = _potentialSpawnPos;
			_dir = _potentialSpawnDir;
			break;
		};
	} forEach (_carrierSettings call BIS_fnc_arrayShuffle);
} else {
	private _taxiNodes = _sector getVariable "BIS_WL_runwaySpawnPosArr";
	private _taxiNodesCnt = count _taxiNodes;
	private _checks = 0;
	while {count _spawnPos == 0 && _checks < 100} do {
		_checks = _checks + 1;
		private _i = (floor random _taxiNodesCnt) max 1;
		private _pointB = _taxiNodes # _i;
		private _pointA = _taxiNodes # (_i - 1);
		_dir = _pointA getDir _pointB;
		private _pos = [_pointA, random (_pointA distance2D _pointB), _dir] call BIS_fnc_relPos;
		if (count (_pos nearObjects ["AllVehicles", 20]) == 0) then {
			_spawnPos = _pos;
		};
		sleep 0.001;
	};
};

if (count _spawnPos == 0) exitWith {
	diag_log format ["Ordering aircraft failed. Spawn position not found in sector %1.", _sector getVariable "WL2_name"];
	"No suitable spawn position found. Clear the runways." remoteExec ["systemChat", _owner];
	_sender setVariable ["BIS_WL_isOrdering", false, [2, _owner]];

	// refund if nothing spawned
	[_cost, getPlayerUID _sender] call WL2_fnc_fundsDatabaseWrite;
};

private _isUav = getNumber (configFile >> "CfgVehicles" >> _class >> "isUav") == 1;
private _asset = if (_isUav) then {
	[_spawnPos, _class, _orderedClass, [[0, 0, 1], [0, 1, 0]], false, _sender] call WL2_fnc_createUAVCrew;
} else {
	createVehicle [_class, _spawnPos, [], 0, "NONE"];
};

_asset setVehiclePosition [_spawnPos, [], 0, "CAN_COLLIDE"];
_asset setDir _dir;

[_asset, _sender, _orderedClass] call WL2_fnc_processOrder;

if (!_isUav) then {
	private _memoryPoint = getText (configFile >> "CfgVehicles" >> _class >> "memoryPointsGetInDriver");
	private _memoryPointPosition = _asset selectionPosition _memoryPoint;
	private _actualPosition = _asset modelToWorld _memoryPointPosition;
	_sender setVehiclePosition [_actualPosition, [], 0, "CAN_COLLIDE"];
};