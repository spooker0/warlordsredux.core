#include "includes.inc"
params ["_sector", "_owner"];

private _sectorValue = _sector getVariable ["BIS_WL_value", 50];
private _garrisonSize = _sectorValue * 1.3;

private _vehicleUnits = [];

private _presetVehicles = _sector getVariable ["WL2_vehiclesToSpawn", []];
if (count _presetVehicles == 0) then {
	private _hasRadar = false;
	private _hardAIMode = WL_HARD_AI_MODE == 1;
	private _numVehicleSpawn = if (_hardAIMode) then {
		((_sectorValue / 5) max 1) min 4;
	} else {
		3;
	};

	private _randomSpots = [_sector] call WL2_fnc_findSpawnsInSector;

	private _vehiclesPool = [];
	{
		private _class = _x;
		private _data = _y;
		private _vehicleSpawn = _data getOrDefault ["vehicleSpawn", 0];
		if (_vehicleSpawn > 0) then {
			private _cost = _data getOrDefault ["cost", 0];
			if (_sectorValue <= 10 && _cost >= 3000) then {
				continue;
			};
			if (_sectorValue <= 20 && _cost >= 8000) then {
				continue;
			};
			if (_sectorValue > 20 && _cost <= 3000) then {
				continue;
			};
			_vehiclesPool pushBack _class;
		};
	} forEach WL_ASSET_DATA;

	for "_i" from 1 to _numVehicleSpawn do {
		if (count _randomSpots == 0) then {
			_randomSpots = [_sector] call WL2_fnc_findSpawnsInSector;
		};
		private _spawnPos = selectRandom _randomSpots;
		_randomSpots = _randomSpots select {
			_x distance2D _spawnPos > 30
		};

		private _vehicleArray = [_spawnPos, random 360, selectRandom _vehiclesPool, _owner] call BIS_fnc_spawnVehicle;
		_vehicleArray params ["_vehicle", "_crew", "_group"];

		_vehicle setVehiclePosition [getPosATL _vehicle, [], 10, "NONE"];

		_vehicleUnits pushBack _vehicle;

		{
			_x call WL2_fnc_newAssetHandle;
			_vehicleUnits pushBack _x;
		} forEach _crew;

		[_vehicle, driver _vehicle, typeof _vehicle] call WL2_fnc_processOrder;

		[_group, 0] setWaypointPosition [position _vehicle, 100];
		_group setBehaviour "COMBAT";
		_group deleteGroupWhenEmpty true;

		_wp = _group addWaypoint [_spawnPos, 100];
		_wp setWaypointType "SAD";

		_wp = _group addWaypoint [_spawnPos, 100];
		_wp setWaypointType "CYCLE";

		_vehicle allowCrewInImmobile [true, true];
		[_vehicle, [1, 1, 1]] remoteExec ["setVehicleTIPars", 0];

		if (typeOf _vehicle == "I_LT_01_scout_F") then {
			_hasRadar = true;

			_vehicle setVehicleReportRemoteTargets true;
			_vehicle setVehicleReceiveRemoteTargets true;
			_vehicle setVehicleReportOwnPosition true;
		};
	};

	if (_hasRadar && _hardAIMode) then {
		private _samLocation = selectRandom ([_sector] call WL2_fnc_findSpawnsInSector);
		private _createSamResult = [_samLocation, 0, "I_E_SAM_System_03_F", resistance] call BIS_fnc_spawnVehicle;
		private _sam = _createSamResult select 0;
		for "_i" from 1 to 10 do {
			_sam addMagazineTurret ["magazine_Missile_mim145_x4", [0]];
		};

		_sam setVehicleReportRemoteTargets true;
		_sam setVehicleReceiveRemoteTargets true;
		_sam setVehicleReportOwnPosition true;

		_sam call WL2_fnc_newAssetHandle;
		_vehicleUnits pushBack _sam;
	};
} else {
	{
		private _vehicleInfo = _x;
		_vehicleInfo params ["_type", "_pos", "_dir"];
		private _vehicleArray = [_pos, _dir, _type, _owner] call BIS_fnc_spawnVehicle;
		_vehicleArray params ["_vehicle", "_crew", "_group"];

		_vehicleUnits pushBack _vehicle;

		{
			_x call WL2_fnc_newAssetHandle;
			_vehicleUnits pushBack _x;
		} forEach _crew;

		[_vehicle, driver _vehicle, typeof _vehicle] call WL2_fnc_processOrder;

		private _posVic = position _vehicle;
		[_group, 0] setWaypointPosition [_posVic, 100];
		_group setBehaviour "COMBAT";
		_group deleteGroupWhenEmpty true;

		private _wp = _group addWaypoint [_posVic, 100];
		_wp setWaypointType "SAD";

		private _wp1 = _group addWaypoint [_posVic, 100];
		_wp1 setWaypointType "CYCLE";

		_vehicle allowCrewInImmobile [true, true];
		[_vehicle, [1, 1, 1]] remoteExec ["setVehicleTIPars", 0];
	} forEach _presetVehicles;
};

private _services = _sector getVariable ["WL2_services", []];
if ("H" in _services) then {
	private _aircraftPool = [];
	{
		private _class = _x;
		private _data = _y;
		private _aircraftSpawn = _data getOrDefault ["aircraftSpawn", 0];
		if (_aircraftSpawn > 0) then {
			_aircraftPool pushBack _class;
		};
	} forEach WL_ASSET_DATA;

	private _numAirSpawn = (round (random 3)) max 1;
	for "_i" from 1 to _numAirSpawn do {
		private _randomAngle = random 360;
		private _randomDistance = 2000 + random 500;
		private _randomPos = _sector getPos [_randomDistance, _randomAngle];
		_randomPos set [2, 800];

		private _vehicleArray = [_randomPos, 0, selectRandom _aircraftPool, _owner] call BIS_fnc_spawnVehicle;
		_vehicleArray params ["_vehicle", "_crew", "_group"];

		_vehicle call WL2_fnc_newAssetHandle;
		_vehicleUnits pushBack _vehicle;

		{
			_x call WL2_fnc_newAssetHandle;
			_vehicleUnits pushBack _x;
		} forEach _crew;

		[_group, 0] setWaypointPosition [position _vehicle, 300];
		_group setBehaviour "COMBAT";
		_group deleteGroupWhenEmpty true;

		_wp1 = _group addWaypoint [position _sector vectorAdd [0, 0, 300], 300];
		_wp1 setWaypointType "SAD";

		_wp2 = _group addWaypoint [position _sector vectorAdd [0, 0, 300], 300];
		_wp2 setWaypointType "SAD";

		_wp3 = _group addWaypoint [waypointPosition _wp1 vectorAdd [0, 0, 300], 300];
		_wp3 setWaypointType "CYCLE";

		_vehicle allowCrewInImmobile [true, true];
		[_vehicle, [1, 1, 1]] remoteExec ["setVehicleTIPars", 0];
	};
};
[_vehicleUnits, _sector] spawn WL2_fnc_assetRelevanceCheck;

private _spawnPosArr = [_sector] call WL2_fnc_findSpawnsInSector;
if (count _spawnPosArr == 0) exitWith {};

private _unitsPool = [];
{
    private _class = _x;
    private _data = _y;
    private _unitSpawn = _data getOrDefault ["unitSpawn", 0];
    if (_unitSpawn > 0) then {
        _unitsPool pushBack _class;
    };
} forEach WL_ASSET_DATA;

private _infantryUnits = [];
private _infantryGroups = [];
private _spawnedUnitCount = 0;
while {_spawnedUnitCount < _garrisonSize} do {
	private _pos = selectRandom _spawnPosArr;
	/*
	//***Spawning Diag code, visual tool for spawn points***
	{
       	private _posNumber = str _x;
    	_mrkr = createMarkerLocal [_posNumber, _x];
		_mrkr setMarkerColorLocal "ColorRed";
    	_mrkr setMarkerTypeLocal "loc_LetterX";
    	_mrkr setMarkerSizeLocal [1, 1];
    } forEach _spawnPosArr;

    private _posNumber = str _i;
    _mrkr = createMarkerLocal [_posNumber, _pos];
    _mrkr setMarkerTypeLocal "mil_dot_noShadow";
    _mrkr setMarkerSizeLocal [1.5, 1.5];
	//***end diag code block***
	*/
	private _infantryGroup = createGroup [_owner, true];
	_infantryGroups pushBack _infantryGroup;

	private _grpSize = floor (5 + random 3);
	for "_i" from 1 to _grpSize do {
		private _newUnit = _infantryGroup createUnit [selectRandom _unitsPool, _pos, [], 30, "NONE"];
		private _posAboveGround = getPosATL _newUnit;
		_posAboveGround set [2, 100];
		_newUnit setVehiclePosition [_posAboveGround, [], 0, "CAN_COLLIDE"];
		_newUnit call WL2_fnc_newAssetHandle;
		doStop _newUnit;
		_infantryUnits pushBack _newUnit;

		_spawnedUnitCount = _spawnedUnitCount + 1;
		if (_spawnedUnitCount >= _garrisonSize) then {
			break;
		};
		uiSleep 0.001;
	};
};

[_infantryUnits, _sector] spawn WL2_fnc_assetRelevanceCheck;

private _ownedVehicles = missionNamespace getVariable ["BIS_WL_ownedVehicles_server", []];
_ownedVehicles append (_vehicleUnits + _infantryUnits);
missionNamespace setVariable ["BIS_WL_ownedVehicles_server", _ownedVehicles];