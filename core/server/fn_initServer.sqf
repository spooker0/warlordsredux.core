#include "..\warlords_constants.inc"

["server_init"] call BIS_fnc_startLoadingScreen;

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

missionNamespace setVariable ["gameStart", serverTime, true];

if !(isDedicated) then {
	waitUntil {
		!isNull player && {isPlayer player}
	};
};

call WL2_fnc_sectorsInitServer;
"setup" call WL2_fnc_handleRespawnMarkers;
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
0 spawn WL2_fnc_wlac;
call WL2_fnc_processRunways;

0 spawn WL2_fnc_cleanupCarrier;
0 spawn WL2_fnc_laserTracker;

0 spawn {
	while {!BIS_WL_missionEnd} do {
		_overcastPreset = random 1;
		7200 setOvercast _overcastPreset;
		waitUntil {
			sleep 600;
			0 setFog 0;
			10e10 setFog 0;
			0 setRain 0;
			10e10 setRain 0;
			simulWeatherSync;
			abs (overcast - _overcastPreset) < 0.2
		};
	};
};

0 spawn WL2_fnc_updateVehicleList;

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
			sleep 30;
		};
	};
};

["server_init"] call BIS_fnc_endLoadingScreen;

#if WL_EASTER_EGG
private _systemTime = systemTimeUTC;
if (_systemTime # 1 == 4 && _systemTime # 2 <= 2) then {
	missionNamespace setVariable ["WL_easterEggOverride", true, true];
};
#endif