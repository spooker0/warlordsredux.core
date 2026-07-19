#include "includes.inc"
WL_Server_LoadingState = 0;

#if WL_DEBUG_INIT
0 spawn {
	if (isServer) then {
		uiSleep 1;
		while { WL_Server_LoadingState < 12 } do {
			private _message = format ["[Server Init] Stage %1", WL_Server_LoadingState];
			[_message] remoteExec ["diag_log", 0];
			uiSleep 1;
		};
	};
};
#endif

if !(isDedicated) then {
	waitUntil {
		!(isNull (findDisplay 46)) && !(isNull player);
	};
};

WL_Server_LoadingState = 1;

call WL2_fnc_varsInit;

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
	private _totalSectorCount = missionNamespace getVariable ["WL2_totalSectors", -1];
	waitUntil {
		uiSleep 0.01;
		private _validSectors = BIS_WL_allSectors select {
			!isNull _x
		} select {
			private _name = _x getVariable ["WL2_name", ""];
			_name != ""
		} select {
			private _objArea = _x getVariable ["WL2_objectArea", []];
			count _objArea >= 4
		};
		count _validSectors == _totalSectorCount;
	};
};

WL_Server_LoadingState = 5;

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
			private _sector = _x;
			private _sectorName = _sector getVariable ["WL2_name", "Sector"];
			if (isNil {_sector getVariable "BIS_WL_owner"}) then {
				_initComplete = false;
				diag_log format ["Missing BIS_WL_owner on sector %1", _sectorName];
			};
			if (isNil {_sector getVariable "WL2_capturableBySides"}) then {
				_initComplete = false;
				diag_log format ["Missing WL2_capturableBySides on sector %1", _sectorName];
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