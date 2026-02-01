#include "includes.inc"
{
	createCenter _x;
} forEach [west, east, resistance, civilian];

west setFriend [east, 0];
west setFriend [resistance, 0];
west setFriend [civilian, 1];

east setFriend [west, 0];
east setFriend [resistance, 0];
east setFriend [civilian, 1];

resistance setFriend [west, 0];
resistance setFriend [east, 0];
resistance setFriend [civilian, 1];

civilian setFriend [west, 1];
civilian setFriend [east, 1];
civilian setFriend [resistance, 1];

#if WL_FACTION_THREE_ENABLED
{
	private _group = createGroup independent;
	_group deleteGroupWhenEmpty true;

	private _unit = _group createUnit ["I_Soldier_TL_F", [-1000, -1000, 0], [], 0, "NONE"];
	_unit setVariable ["WL2_isPlayableGreen", true, true];
	_unit allowDamage false;
} forEach [1, 2, 3, 4, 5];
#endif

call SQD_fnc_initServer;

call WL2_fnc_serverEHs;

estimatedTimeLeft WL_DURATION_MISSION;

0 spawn {
	waitUntil {
		uiSleep 1;
		estimatedEndServerTime - serverTime < 1;
	};
	missionNamespace setVariable ["BIS_WL_missionEnd", true, true];

	[independent] spawn WL2_fnc_calculateEndResults;

	[independent, false, true] remoteExec ["WL2_fnc_missionEndHandle", 0];
	[independent, false, false] spawn WL2_fnc_missionEndHandle;
};

if !(isDedicated) then {
	waitUntil {
		!isNull player && {isPlayer player}
	};
};

call WL2_fnc_sectorsInitServer;
if !(isDedicated) then {
	{
		_x call WL2_fnc_parsePurchaseList;
	} forEach BIS_WL_sidesArray;
};
0 spawn WL2_fnc_detectNewPlayers;
["server", true] call WL2_fnc_updateSectorArrays;
0 spawn WL2_fnc_targetSelectionHandleServer;
0 spawn WL2_fnc_incomePayoff;
0 spawn WL2_fnc_garbageCollector;
0 spawn WL2_fnc_runwayCollector;
call WL2_fnc_processRunways;

0 spawn WL2_fnc_cleanupCarrier;
0 spawn WL2_fnc_laserTracker;
0 spawn WL2_fnc_assetRelevanceCheck;
0 spawn WL2_fnc_sectorRespawner;

0 spawn {
	if (random 1 > 0.1) exitWith {};

	waitUntil { time > 0 };

	private _dateTime = systemTime select [0, 5];
	_dateTime set [3, round random 24];
	_dateTime set [4, 0];
	[_dateTime] remoteExec ["setDate"];

	uiSleep 10;

	while { !BIS_WL_missionEnd } do {
		private _timeMultiplier = if (sunOrMoon < 0.99) then {
			30;
		} else {
			1;
		};
		if (timeMultiplier != _timeMultiplier) then {
			setTimeMultiplier _timeMultiplier;
		};
		uiSleep (60 * 2);
	};
};

#if WL_SNOW_ENABLED
0 spawn {
	[
		"a3\data_f\snowflake4_ca.paa",
		4,
		0.01,
		25,
		0.05,
		2.5,
		0.5,
		0.5,
		0.07,
		0.07,
		[1, 1, 1, 0.5],
		0.0,
		0.2,
		0.5,
		0.5,
		true,
		false
	] call BIS_fnc_setRain;

	private _timesTriggered = 0;
	while { !BIS_WL_missionEnd && _timesTriggered < 3 } do {
		private _snowIntensity = random 1;
		if (_snowIntensity < 0.4) then {
			_snowIntensity = 0.4;
		};

		0 setOvercast (_snowIntensity * 2);
		0 setRain _snowIntensity;
		0 setFog (_snowIntensity * 0.13);
		setHumidity (0.9 * _snowIntensity);
		forceWeatherChange;

		_timesTriggered = _timesTriggered + 1;

		uiSleep (60 * 30);
	};

	0 setOvercast 0;
	0 setRain 0;
	0 setFog 0;
	setHumidity 0;
	forceWeatherChange;
};
#endif

#if WL_EARTHQUAKE_ENABLED
0 spawn {
	uiSleep 10;
	while { !BIS_WL_missionEnd } do {
		if (random 1 < 0.01) then {
			[] remoteExec ["WL2_fnc_earthquake", 0];
		};
		uiSleep (60 * 20);
	};
};
#endif

0 spawn WL2_fnc_updateVehicleList;
0 spawn WL2_fnc_generateScoreboard;

#if WL_ZEUS_ENABLED == 0
{
	deleteVehicle _x;
} forEach (allMissionObjects "ModuleCurator_F");
#endif

if !(["(EU) #11", serverName] call BIS_fnc_inString) then {
	0 spawn {
		while {!BIS_WL_missionEnd} do {
			private _allEntities = entities [[], ["Logic"], true];
			private _allNonLocalEntities = _allEntities select { owner _x != 0 };
			{
				_x addCuratorEditableObjects [_allNonLocalEntities, true];
			} forEach allCurators;
			uiSleep 30;
		};
	};
};

private _serverStats = profileNamespace getVariable ["WL_stats", createHashMap];
missionNamespace setVariable ["WL_serverStats", _serverStats, true];

#if WL_EASTER_EGG
private _systemTime = systemTimeUTC;
if (_systemTime # 1 == 4 && _systemTime # 2 <= 2) then {
	missionNamespace setVariable ["WL_easterEggOverride", true, true];
};
#endif