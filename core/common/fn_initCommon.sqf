0 spawn APS_fnc_defineVehicles;

if !(isDedicated) then {
	call GFE_fnc_credits;
	waitUntil { !isNull player };
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
		_expectedSectors = _expectedSectors apply { _x getVariable ["BIS_WL_name", ""] };
		private _foundSectors = (entities "Logic") select { _x getVariable ["BIS_WL_name", ""] != "" } apply { _x getVariable ["BIS_WL_name", ""] };
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

BIS_WL_allSectors = (entities "Logic") select { _x getVariable ["BIS_WL_name", ""] != "" };

{
	private _sector = _x;

	if (count (_x getVariable ["objectArea", []]) == 0) then {
		private _nearDetectors = _x nearObjects ["EmptyDetector", 100];
		_x setVariable ["objectArea", triggerArea (_nearDetectors # 0)];
	};

	private _sectorArea = _sector getVariable "objectArea";
	private _connections = _sector getVariable ["BIS_WL_connectedSectors", []];
	{
		if (typeof _x == "Logic") then {
			_connections pushBackUnique _x;
		};
	} forEach (synchronizedObjects _sector);
	_sector setVariable ["BIS_WL_connectedSectors", _connections];
	_sector setVariable ["objectAreaComplete", [position _sector] + _sectorArea];
} forEach BIS_WL_allSectors;

{_x enableSimulation false} forEach allMissionObjects "EmptyDetector";

"common" call WL2_fnc_varsInit;

enableSaving [false, false];

call WL2_fnc_tablesSetUp;
call WLC_fnc_init;

if (isServer) then {
	call WL2_fnc_initServer;
} else {
	waitUntil {{isNil _x} count [
		"BIS_WL_base1",
		"BIS_WL_base2",
		"gameStart",
		"BIS_WL_currentTarget_west",
		"BIS_WL_currentTarget_east",
		"BIS_WL_wrongTeamGroup"
	] == 0};

	waitUntil {{isNil {_x getVariable "BIS_WL_originalOwner"}} count [BIS_WL_base1, BIS_WL_base2] == 0};

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