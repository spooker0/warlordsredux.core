#include "includes.inc"
0 spawn APS_fnc_defineVehicles;

if !(isDedicated) then {
	waitUntil {
		!(isNull (findDisplay 46)) && !(isNull player);
	};
};

if (isServer) then {
	call WL2_fnc_initSectors;
} else {
	["client_init"] call BIS_fnc_startLoadingScreen;

	private _sectorsReady = false;
	while { !_sectorsReady } do {
		sleep 0.01;
		private _expectedSectors = missionNamespace getVariable "WL2_sectorsInitializationComplete";
		if (isNil "_expectedSectors") then {
			continue;
		};
		_expectedSectors = _expectedSectors apply { _x getVariable ["WL2_name", ""] };
		private _foundSectors = (entities "Logic") select { _x getVariable ["WL2_name", ""] != "" } apply { _x getVariable ["WL2_name", ""] };
		private _foundAllSectors = true;
		{
			if !(_x in _foundSectors) then {
				_foundAllSectors = false;
			};
		} forEach _expectedSectors;
		if (_foundAllSectors) then {
			_sectorsReady = true;
		};
	};
};

BIS_WL_allSectors = (entities "Logic") select { _x getVariable ["WL2_name", ""] != "" };

{
	private _sector = _x;

	if (count (_x getVariable ["WL2_objectArea", []]) == 0) then {
		private _nearDetectors = _x nearObjects ["EmptyDetector", 100];
		_x setVariable ["WL2_objectArea", triggerArea (_nearDetectors # 0)];
	};

	private _sectorArea = _sector getVariable "WL2_objectArea";
	private _connections = _sector getVariable ["WL2_connectedSectors", []];
	{
		if (typeof _x == "Logic") then {
			_connections pushBackUnique _x;
		};
	} forEach (synchronizedObjects _sector);
	_sector setVariable ["WL2_connectedSectors", _connections];
	_sector setVariable ["objectAreaComplete", [position _sector] + _sectorArea];
} forEach BIS_WL_allSectors;

{_x enableSimulation false} forEach allMissionObjects "EmptyDetector";

"common" call WL2_fnc_varsInit;

enableSaving [false, false];

call WL2_fnc_initAssetData;
call WLC_fnc_init;

private _lastUpdateVersion = profileNamespace getVariable ["WL2_lastUpdateVersion", ""];
if (_lastUpdateVersion != WL_VERSION) then {
	profileNamespace setVariable ["WL2_lastUpdateVersion", WL_VERSION];
	profileNamespace setVariable ["WL2_loadoutDefaults", createHashmap];
};

if (isServer) then {
	call WL2_fnc_initServer;
} else {
	waitUntil {{isNil _x} count [
		"WL2_base1",
		"WL2_base2",
		"gameStart",
		"BIS_WL_currentTarget_west",
		"BIS_WL_currentTarget_east"
	] == 0};

	waitUntil {{isNil {_x getVariable "BIS_WL_originalOwner"}} count [WL2_base1, WL2_base2] == 0};

	{
		_sector = _x;
		waitUntil {{isNil {_sector getVariable _x}} count [
			"BIS_WL_owner",
			"BIS_WL_previousOwners",
			"BIS_WL_agentGrp"
		] == 0};
	} forEach BIS_WL_allSectors;
};

if (!isDedicated && hasInterface) then {
	call WL2_fnc_initClient;
};