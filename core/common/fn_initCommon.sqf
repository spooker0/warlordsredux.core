0 spawn APS_fnc_defineVehicles;

if !(isDedicated) then {
	call GFE_fnc_credits;
	waitUntil { !isNull player };
};

BIS_WL_allSectors = (entities "Logic") select {count synchronizedObjects _x > 0};

{
	_x setVariable ["objectArea", triggerArea ((_x nearObjects ["EmptyDetector", 100]) # 0)];
	if (isNil {_x getVariable "BIS_WL_services"}) then {
		_x setVariable ["BIS_WL_services", []];
	};
} forEach BIS_WL_allSectors;

{_x enableSimulation false} forEach allMissionObjects "EmptyDetector";

"common" call WL2_fnc_varsInit;

enableSaving [false, false];

call WL2_fnc_tablesSetUp;
call WLC_fnc_init;

{
	private _sector = _x;
	_sector setVariable ["BIS_WL_connectedSectors", (synchronizedObjects _sector) select {typeOf _x == "Logic"}];
	_sector setVariable ["objectAreaComplete", [position _sector] + (_sector getVariable "objectArea")];
	private _axisA = (_sector getVariable "objectArea") # 0;
	private _axisB = (_sector getVariable "objectArea") # 1;
	_sector setVariable ["BIS_WL_maxAxis", if ((_sector getVariable "objectArea") # 3) then {sqrt ((_axisA ^ 2) + (_axisB ^ 2))} else {_axisA max _axisB}];
} forEach BIS_WL_allSectors;

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
	call WL2_fnc_initClient
};