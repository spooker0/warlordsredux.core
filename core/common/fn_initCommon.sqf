#include "includes.inc"
if !(isDedicated) then {
	waitUntil {
		!(isNull (findDisplay 46)) && !(isNull player);
	};
};

if (hasInterface) then {
	["main"] call BIS_fnc_startLoadingScreen;
};

0 spawn APS_fnc_defineVehicles;

if (isServer) then {
	call WL2_fnc_initSectors;
} else {
	private _sectorsReady = false;
	while { !_sectorsReady } do {
		uiSleep 0.1;
		private _expectedSectors = missionNamespace getVariable "WL2_sectorsInitializationComplete";
		if (isNil "_expectedSectors") then {
			continue;
		};
		_expectedSectors = _expectedSectors apply { _x getVariable ["WL2_name", ""] };
		private _foundSectors = (entities "Logic") select {
			private _name = _x getVariable ["WL2_name", ""];
			private _objArea = _x getVariable ["WL2_objectArea", []];
			private _agentGrp = _x getVariable ["BIS_WL_agentGrp", grpNull];
			_name != "" && (count _objArea >= 4) && !isNull _agentGrp
		} apply { _x getVariable ["WL2_name", ""] };
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

private _lastUpdateVersion = profileNamespace getVariable ["WL2_lastUpdateVersion", ""];
if (_lastUpdateVersion != WL_VERSION) then {
	profileNamespace setVariable ["WL2_lastUpdateVersion", WL_VERSION];
	profileNamespace setVariable ["WL2_loadoutDefaults", createHashmap];
	profileNamespace setVariable ["WLM_appearanceDefaults", createHashmap];
};

if (isServer) then {
	call WL2_fnc_initServer;
} else {
	private _initComplete = false;

	while {_initComplete} do {
		_initComplete = true;
		{
			if (isNil _x) then {
				_initComplete = false;
				diag_log format ["Missing %1", _x];
			};
		} forEach [
			"WL2_base1",
			"WL2_base2",
			"BIS_WL_currentTarget_west",
			"BIS_WL_currentTarget_east"
		];

		{
			if (isNil {_x getVariable "BIS_WL_originalOwner"}) then {
				_initComplete = false;
				diag_log format ["Missing BIS_WL_originalOwner on %1", _x];
			};
		} forEach [WL2_base1, WL2_base2];

		{
			private _sector = _x;
			private _sectorName = _sector getVariable ["WL2_name", "Sector"];
			if (isNil {_sector getVariable "BIS_WL_owner"}) then {
				_initComplete = false;
				diag_log format ["Missing BIS_WL_owner on sector %1", _sectorName];
			};
			if (isNil {_sector getVariable "BIS_WL_previousOwners"}) then {
				_initComplete = false;
				diag_log format ["Missing BIS_WL_previousOwners on sector %1", _sectorName];
			};
			if (isNil {_sector getVariable "BIS_WL_agentGrp"}) then {
				_initComplete = false;
				diag_log format ["Missing BIS_WL_agentGrp on sector %1", _sectorName];
			};
		} forEach BIS_WL_allSectors;

		uiSleep 0.1;
	};
};

if (!isDedicated && hasInterface) then {
	call WL2_fnc_initClient;
};

if (hasInterface) then {
	["main"] call BIS_fnc_endLoadingScreen;
};