#include "includes.inc"
params ["_flag"];

[_flag] call WL2_fnc_restockAction;

#if WL_TEST_SERVER
	_flag addAction ["<t color='#ffff00'>(Debug) Reset Score/Level to 0</t>", {
		[0] call WLC_fnc_setScore;
	}, [], 5, true, true];
	_flag addAction ["<t color='#ffff00'>(Debug) Add Score +1,000</t>", {
		private _score = ["getScore"] call WLC_fnc_getLevelInfo;
		[_score + 1000] call WLC_fnc_setScore;
	}, [], 5, true, false];
	_flag addAction ["<t color='#ffff00'>(Debug) Add Score +10,000</t>", {
		private _score = ["getScore"] call WLC_fnc_getLevelInfo;
		[_score + 10000] call WLC_fnc_setScore;
	}, [], 5, true, false];
	_flag addAction ["<t color='#ffff00'>(Debug) Add Score +100,000</t>", {
		private _score = ["getScore"] call WLC_fnc_getLevelInfo;
		[_score + 100000] call WLC_fnc_setScore;
	}, [], 5, true, false];
	_flag addAction ["<t color='#ffff00'>(Debug) Set Instant Respawn</t>", {
		setPlayerRespawnTime 1;
	}, [], 5];
	_flag addAction ["<t color='#ffff00'>(Debug) Set Normal Respawn</t>", {
		setPlayerRespawnTime WL_DURATION_RESPAWN;
	}, [], 5];
	_flag addAction ["<t color='#ffff00'>Spawn Green Squadron (Near)</t>", {
		params ["_flag"];
		private _aircraftPool = [];
		{
			private _class = _x;
			private _data = _y;
			private _aircraftSpawn = _data getOrDefault ["aircraftSpawn", 0];
			if (_aircraftSpawn > 0) then {
				_aircraftPool pushBack _class;
			};
		} forEach WL_ASSET_DATA;

		private _vehicleUnits = [];
		for "_i" from 1 to 4 do {
			private _randomAngle = random 360;
			private _randomDistance = 2000 + random 500;
			private _randomPos = _flag getPos [_randomDistance, _randomAngle];
			_randomPos set [2, 1000];

			private _aircraft = [selectRandom _aircraftPool, _randomPos, random 360, false, true, _vehicleUnits, _flag] call WL2_fnc_addGreenVehicle;
			_aircraft setPosASL _randomPos;
			_aircraft setVelocityModelSpace [0, 100, 0];
			_aircraft flyInHeightASL [1000, 1000, 1000];
		};

		[_vehicleUnits, 3600] remoteExec ["WL2_fnc_reportTargets", BIS_WL_playerSide];

		private _ownedVehicles = missionNamespace getVariable ["BIS_WL_ownedVehicles_server", []];
		_ownedVehicles append _vehicleUnits;
		missionNamespace setVariable ["BIS_WL_ownedVehicles_server", _ownedVehicles];
	}, [], 5];

	_flag addAction ["<t color='#ffff00'>Spawn Green Squadron (Far)</t>", {
		params ["_flag"];
		private _aircraftPool = [];
		{
			private _class = _x;
			private _data = _y;
			private _aircraftSpawn = _data getOrDefault ["aircraftSpawn", 0];
			if (_aircraftSpawn > 0) then {
				_aircraftPool pushBack _class;
			};
		} forEach WL_ASSET_DATA;

		private _vehicleUnits = [];
		for "_i" from 1 to 4 do {
			private _randomAngle = random 360;
			private _randomDistance = 20000 - random 10000;
			private _randomPos = _flag getPos [_randomDistance, _randomAngle];
			_randomPos set [2, 1000];

			private _aircraft = [selectRandom _aircraftPool, _randomPos, random 360, false, true, _vehicleUnits, _flag] call WL2_fnc_addGreenVehicle;
			_aircraft setPosASL _randomPos;
			_aircraft setVelocityModelSpace [0, 100, 0];
			_aircraft flyInHeightASL [1000, 1000, 1000];
		};

		[_vehicleUnits, 3600] remoteExec ["WL2_fnc_reportTargets", BIS_WL_playerSide];

		private _ownedVehicles = missionNamespace getVariable ["BIS_WL_ownedVehicles_server", []];
		_ownedVehicles append _vehicleUnits;
		missionNamespace setVariable ["BIS_WL_ownedVehicles_server", _ownedVehicles];
	}, [], 5];
#endif