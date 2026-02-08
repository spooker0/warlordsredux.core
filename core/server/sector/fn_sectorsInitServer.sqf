#include "includes.inc"
private _baseData =
#if WL_OVERRIDE_BASES
	BIS_WL_allSectors select {
		_x getVariable ["WL2_name", ""] in ["AAC Airfield", "Airbase"];
	};
#else
	[] call WL2_fnc_calcHomeBases;
#endif

#if WL_BASE_SELECTION_DEBUG
private _baseProbabilityTable = [];
private _minDistance = 10000;
private _minDistanceBase1 = objNull;
private _minDistanceBase2 = objNull;
for "_i" from 0 to 10000 do {
	private _testData = [] call WL2_fnc_calcHomeBases;
	private _firstBase = _testData # 0;
	private _secondBase = _testData # 1;

	private _firstEntry = _baseProbabilityTable findIf {
		_x # 0 == _firstBase;
	};
	if (_firstEntry == -1) then {
		_baseProbabilityTable pushBack [_firstBase, 1];
	} else {
		(_baseProbabilityTable # _firstEntry) set [1, (_baseProbabilityTable # _firstEntry) # 1 + 1];
	};

	private _secondEntry = _baseProbabilityTable findIf {
		_x # 0 == _secondBase;
	};
	if (_secondEntry == -1) then {
		_baseProbabilityTable pushBack [_secondBase, 1];
	} else {
		(_baseProbabilityTable # _secondEntry) set [1, (_baseProbabilityTable # _secondEntry) # 1 + 1];
	};

	private _distance = _firstBase distance2D _secondBase;
	if (_distance < _minDistance) then {
		_minDistance = _distance;
		_minDistanceBase1 = _firstBase;
		_minDistanceBase2 = _secondBase;
	};
};

diag_log format ["Min distance: %1, Bases: %2, %3", _minDistance, _minDistanceBase1 getVariable ["WL2_name", ""], _minDistanceBase2 getVariable ["WL2_name", ""]];

private _sortedSectorsArray = [_baseProbabilityTable, [], { _x # 1 }, "DESCEND"] call BIS_fnc_sortBy;

diag_log "Base probability table:";
{
	private _getPairs = ([_x # 0] call WL2_fnc_calcHomeBases) # 2;
	diag_log format ["%1: %2%%, Pairs: %3", (_x # 0) getVariable ["WL2_name", ""], (_x # 1) / 20000 * 100, count _getPairs];
} forEach _sortedSectorsArray;
#endif

private _firstBase = _baseData # 0;
private _secondBase = _baseData # 1;

#if WL_BASE_SELECTION_DEBUG
systemChat format ["First base: %1", _firstBase getVariable ["WL2_name", ""]];
systemChat format ["Second base: %1", _secondBase getVariable ["WL2_name", ""]];
#endif

createMarker ["respawn_west", getPosATL _firstBase];
createMarker ["respawn_east", getPosATL _secondBase];

missionNamespace setVariable ["WL2_base1", _firstBase, true];
missionNamespace setVariable ["WL2_base2", _secondBase, true];
waitUntil {!isNil "WL2_base1" && {!isNil "WL2_base2"}};

{
	_side = [west, east] # _forEachIndex;
	_base = _x;
	_base setVariable ["BIS_WL_owner", _side, true];
	_base setVariable ["BIS_WL_originalOwner", _side, true];
	_base setVariable ["BIS_WL_previousOwners", [_side], true];
	_base setVariable ["BIS_WL_revealedBy", [_side], true];
	_pos = (position _x) findEmptyPosition [0, 20, "FlagPole_F"];
	_posFinal = if (count _pos == 0) then {
		position _x
	} else {
		_pos
	};
	private _flag = createVehicle ["FlagPole_F", _posFinal, [], 0,"CAN_COLLIDE"];
	if (_side == west) then {
		_flag setFlagTexture "\A3\Data_F\Flags\flag_NATO_CO.paa";
	} else {
		_flag setFlagTexture "\A3\Data_F\Flags\Flag_CSAT_CO.paa";
	};
	_flag setFlagSide _side;
	[_flag] remoteExec ["WLC_fnc_action", 0, true];
} forEach [_firstBase, _secondBase];

#if WL_QUICK_CAPTURE
private _fastestCapture = 0.2;
private _slowestCapture = 0.5;
#else
private _fastestCapture = 20;
private _slowestCapture = 50;
#endif

private _sectorGroup = createGroup [civilian, true];
{
	private _sector = _x;
	if (isNull _sector) then {
		continue;
	};

	private _sectorPos = position _sector;
	if ((_sector getVariable ["BIS_WL_owner", sideUnknown]) == sideUnknown) then {
		_sector setVariable ["BIS_WL_owner", resistance, true];
		_sector setVariable ["BIS_WL_previousOwners", [], true];
		[_sector] remoteExec ['WL2_fnc_sectorRevealHandle', [0, -2] select isDedicated];
	};

	private _area = _sector getVariable "WL2_objectArea";
	_area set [4, 38];
	_area params ["_a", "_b", "_angle", "_isRectangle"];
	private _size = _a * _b * (if (_isRectangle) then {4} else {pi});
	private _sectorValue = round (_size / 13000);

	_sector setVariable ["BIS_WL_value", _sectorValue, true];

	private _agent = _sectorGroup createUnit ["Logic", _sectorPos, [], 0, "CAN_COLLIDE"];
	_agent enableSimulationGlobal false;

	private _minCaptureTime = linearConversion [5, 30, _sectorValue, _fastestCapture, _slowestCapture, true];
	_sector setVariable ["WL2_minCapture", _minCaptureTime];
} forEach BIS_WL_allSectors;

0 spawn WL2_fnc_sectorCaptureHandle;

#if WL_OVERRIDE_BASES
0 spawn {
	uiSleep 3;
	private _westSectors = BIS_WL_allSectors select {
		_x getVariable ["WL2_name", ""] in ["Poliakko", "Alikampos", "Lakka"];
	};
	private _eastSectors = BIS_WL_allSectors select {
		_x getVariable ["WL2_name", ""] in ["Stavros", "Neochori", "Katalaki"];
	};
	{
		_x setVariable ["BIS_WL_revealedBy", [west], true];
		[_x, west] call WL2_fnc_sectorRevealHandle;
		[_x, west] call WL2_fnc_changeSectorOwnership;
	} forEach _westSectors;
	{
		_x setVariable ["BIS_WL_revealedBy", [east], true];
		[_x, east] call WL2_fnc_sectorRevealHandle;
		[_x, east] call WL2_fnc_changeSectorOwnership;
	} forEach _eastSectors;

	private _sectorsInPlay = missionNamespace getVariable ["WL2_sectorsInPlay", []];
	_sectorsInPlay append _westSectors;
	_sectorsInPlay append _eastSectors;
	missionNamespace setVariable ["WL2_sectorsInPlay", _sectorsInPlay];
};
#endif

#if WL_AA_TEST
[_firstBase, _secondBase] spawn {
	private _airDefenseToSpawn = [
		[
			["B_APC_Tracked_01_AA_F", "B_APC_Tracked_01_AA_F"],
			["B_APC_Tracked_01_AA_F", "B_APC_Tracked_01_AA_F"],
			["B_APC_Tracked_01_AA_F", "B_APC_Tracked_01_AA_F"]
		],
		[
			["O_APC_Tracked_02_AA_F", "O_APC_Tracked_02_AA_F"],
			["O_APC_Tracked_02_AA_F", "O_APC_Tracked_02_AA_F"],
			["O_APC_Tracked_02_AA_F", "O_APC_Tracked_02_AA_F"]
		]
	];
	{
		private _sector = _x;
		private _randomSpots = [_sector] call WL2_fnc_findSpawnsInSector;
		{
			private _pos = selectRandom _randomSpots;
			private _direction = [[0, 0, 1], [0, 1, 0]];
			private _realClass = _x # 0;
			private _orderedClass = _x # 1;

			private _asset = [_realClass, _orderedClass, _pos, _direction, false, _spawnInAir] call WL2_fnc_createVehicleCorrectly;
			waitUntil {
				uiSleep 0.1;
				!(isNull _asset)
			};
			private _assetCrewGroup = createVehicleCrew _asset;
			{
				_x setSkill 1;
				_x call WL2_fnc_newAssetHandle;
			} forEach (units _assetCrewGroup);
			[_asset, driver _asset, _orderedClass] call WL2_fnc_processOrder;

			[_asset] spawn {
				params ["_asset"];
				while {alive _asset} do {
					_asset setVehicleAmmo 1;
					{
						(side _asset) reportRemoteTarget [_x, 10];
					} forEach (_asset nearEntities [["Air"], 11000]);
					private _targets = getSensorTargets _asset;
					_targets = _targets select {
						_x # 1 == "air" && _x # 2 != "friendly";
					};
					_targets = _targets apply {
						_x # 0;
					};
					private _targetQueue = [_targets, [_asset], { _input0 distance _x }, "ASCEND"] call BIS_fnc_sortBy;

					if (count _targetQueue > 0) then {
						_asset doFire (_targetQueue # 0);

					};
					uiSleep 5;
				};
			};
		} forEach (_airDefenseToSpawn # _forEachIndex);
	} forEach _this;
};
#endif



private _faces = [];
private _outNeighborsBySectorId = createHashMap;
private _neighborIndexBySectorId = createHashMap;
private _visitedHalfEdges = createHashMap;

private _allSectors = BIS_WL_allSectors;

private _getAngleDegrees2D = {
	params ["_fromSector", "_toSector"];

	private _fromPos = getPosASL _fromSector;
	private _toPos = getPosASL _toSector;

	private _dx = (_toPos # 0) - (_fromPos # 0);
	private _dy = (_toPos # 1) - (_fromPos # 1);

	private _angle = _dy atan2 _dx;
	if (_angle < 0) then { _angle = _angle + 360 };
	_angle
};

private _halfEdgeKey = {
	params ["_fromSector", "_toSector"];
	format ["%1>%2", netId _fromSector, netId _toSector]
};

private _getNextHalfEdge = {
	params ["_fromSector", "_toSector"];

	private _toSectorId = netId _toSector;

	private _sortedNeighbors = _outNeighborsBySectorId get _toSectorId;
	private _neighborIndexMap = _neighborIndexBySectorId get _toSectorId;

	private _reverseIndex = _neighborIndexMap get (netId _fromSector);
	private _degree = count _sortedNeighbors;

	private _nextIndex = (_reverseIndex - 1 + _degree) mod _degree;
	private _nextSector = _sortedNeighbors # _nextIndex;

	[_toSector, _nextSector]
};

private _getFaceArea2D = {
	params ["_sectorsInFace"];

	private _count = count _sectorsInFace;
	private _sum = 0;

	for "_i" from 0 to (_count - 1) do {
		private _a = _sectorsInFace # _i;
		private _b = _sectorsInFace # ((_i + 1) mod _count);

		private _pa = getPosASL _a;
		private _pb = getPosASL _b;

		private _ax = _pa # 0;
		private _ay = _pa # 1;

		private _bx = _pb # 0;
		private _by = _pb # 1;

		_sum = _sum + (_ax * _by - _bx * _ay);
	};

	abs (_sum * 0.5)
};

{
	private _sector = _x;
	private _sectorId = netId _sector;

	private _neighbors = _sector getVariable ["WL2_connectedSectors", []];

	private _sortedNeighbors = [_neighbors, [], {
		params ["_neighbor"];
		[_sector, _neighbor] call _getAngleDegrees2D
	}, "ASCEND"] call BIS_fnc_sortBy;

	_outNeighborsBySectorId set [_sectorId, _sortedNeighbors];

	private _neighborIndexMap = createHashMap;
	for "_index" from 0 to ((count _sortedNeighbors) - 1) do {
		private _neighbor = _sortedNeighbors # _index;
		_neighborIndexMap set [netId _neighbor, _index];
	};

	_neighborIndexBySectorId set [_sectorId, _neighborIndexMap];

} forEach _allSectors;

{
	private _fromSector = _x;
	private _fromSectorId = netId _fromSector;
	private _fromSortedNeighbors = _outNeighborsBySectorId get _fromSectorId;

	{
		private _toSector = _x;

		private _startKey = [_fromSector, _toSector] call _halfEdgeKey;
		if (_visitedHalfEdges getOrDefault [_startKey, false]) then { continue };

		private _sectorsInFace = [];
		private _currentFrom = _fromSector;
		private _currentTo = _toSector;

		while { !(_visitedHalfEdges getOrDefault [[_currentFrom, _currentTo] call _halfEdgeKey, false]) } do {
			private _currentKey = [_currentFrom, _currentTo] call _halfEdgeKey;
			_visitedHalfEdges set [_currentKey, true];

			_sectorsInFace pushBack _currentFrom;

			private _next = [_currentFrom, _currentTo] call _getNextHalfEdge;
			_currentFrom = _next # 0;
			_currentTo = _next # 1;
		};

		_faces pushBack _sectorsInFace;

	} forEach _fromSortedNeighbors;

} forEach _allSectors;

private _facesData = [];
{
	private _sectorsInFace = _x;
	private _area = [_sectorsInFace] call _getFaceArea2D;

	if (_area > 15000000) then {
		continue;
	};

	private _sectorNames = _sectorsInFace apply {
		_x getVariable ["WL2_name", ""]
	};

	_facesData pushBack [_sectorsInFace, _area];
} forEach _faces;
missionNamespace setVariable ["WL2_sectorFaces", _facesData, true];