#include "includes.inc"
WL_Server_LoadingState = 0;

0 spawn {
	uiSleep 1;
	while { WL_Server_LoadingState < 12 } do {
		private _message = format ["[Server Init] Stage %1", WL_Server_LoadingState];
		[_message] remoteExec ["diag_log", 0];
		uiSleep 1;
	};
};

if !(isDedicated) then {
	waitUntil {
		!(isNull (findDisplay 46)) && !(isNull player);
	};
};

WL_Server_LoadingState = 1;
"common" call WL2_fnc_varsInit;

WL_Server_LoadingState = 2;
if (hasInterface) then {
	["main"] call BIS_fnc_startLoadingScreen;
};

WL_Server_LoadingState = 3;
0 spawn APS_fnc_defineVehicles;

WL_Server_LoadingState = 4;
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
			_name != "" && (count _objArea >= 4)
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

WL_Server_LoadingState = 5;
BIS_WL_allSectors = (entities "Logic") select { _x getVariable ["WL2_name", ""] != "" };

{
	private _sector = _x;
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

WL_Server_LoadingState = 6;
private _catapultTriggers = allMissionObjects "EmptyDetector" select {
	private _carrierParts = _x getVariable ["bis_carrierParts", []];
	count _carrierParts > 0
};
{
	deleteVehicle _x;
} forEach _catapultTriggers;

WL_Server_LoadingState = 7;
enableSaving [false, false];

WL_Server_LoadingState = 8;
call WL2_fnc_initAssetData;

WL_Server_LoadingState = 9;
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
		} forEach BIS_WL_allSectors;

		uiSleep 0.1;
	};
};

WL_Server_LoadingState = 10;
if (!isDedicated && hasInterface) then {
	call WL2_fnc_initClient;
};

WL_Server_LoadingState = 11;
call APS_fnc_setupProjectiles;

if (hasInterface) then {
	["main"] call BIS_fnc_endLoadingScreen;
};

WL_Server_LoadingState = 12;