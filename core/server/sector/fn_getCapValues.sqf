#include "..\..\warlords_constants.inc"

params ["_sector"];

private _sideArr = [west, east, independent];
private _sideCaptureModifier = createHashMap;
{
	private _side = _x;

	if (_side == independent) then {
		_sideCaptureModifier set [_side, 2];
		continue;
	};

	private _sideLinkedSectors = BIS_WL_sectorsArrays # (BIS_WL_competingSides find _side) # 2;
	private _neighboringSectors = synchronizedObjects _sector;
	private _connectedNeighboringSectors = _neighboringSectors select {
		typeof _x == "Logic" && _side == _x getVariable "BIS_WL_owner" && _x in _sideLinkedSectors;
	};
	private _hasConnection = count _connectedNeighboringSectors > 0;
	if (!_hasConnection) then {
		_sideCaptureModifier set [_side, 0];
		continue;
	};

	private _previousOwners = _sector getVariable ["BIS_WL_previousOwners", []];
	private _isPreviousOwner = _side in _previousOwners;

	private _sideCurrentTarget = missionNamespace getVariable (format ["BIS_WL_currentTarget_%1", _side]);
	private _isCurrentTarget = _sideCurrentTarget == _sector;
	if (!_isPreviousOwner && !_isCurrentTarget) then {
		_sideCaptureModifier set [_side, 0];
		continue;
	};

	private _connections = count _connectedNeighboringSectors;

	private _currentForwardBases = missionNamespace getVariable ["WL2_forwardBases", []];
	private _teamForwardBases = _currentForwardBases select {
		_x getVariable ["WL2_forwardBaseOwner", sideUnknown] == _side
	};
	private _inRangeTeamForwardBases = _teamForwardBases select {
		_sector distance2D _x < WL_FOB_CAPTURE_RANGE &&
		_x getVariable ["WL2_forwardBaseTime", 0] < serverTime
	};
	_connections = _connections + count _inRangeTeamForwardBases;

	_sideCaptureModifier set [_side, _connections min 3];
} forEach _sideArr;

private _relevantEntities = entities [["LandVehicle", "Man"], ["Logic"], true, true];
private _sectorAO = _sector getVariable "objectAreaComplete";
private _allInArea = (_relevantEntities inAreaArray _sectorAO) select {
	lifeState _x != "INCAPACITATED";
};

// Perf benchmarking result: entities w/ inAreaArray is faster than nearEntities
// private _timeToExecute = diag_codePerformance[{
// 	private _sector = _this # 0;
// 	private _relevantEntities = entities [["LandVehicle", "Man"], ["Logic"], true, true];
// 	private _sectorAO = _sector getVariable "objectAreaComplete";
// 	private _allInArea = _relevantEntities inAreaArray _sectorAO;
// }, [_sector], 100];
// systemChat format ["Time to execute: %1", _timeToExecute];

private _eligibleEntitiesInArea = _allInArea select {
	private _unit = _x;
	// Tested:
	// Underwater = negative Z
	// Swimming on water surface = ~0
	// Clipped under rocks = ~0, nothing to do about it
	// Standing on top of rocks = ~0
	// Standing on top of building/>1 floor = ~0
	// Climbing ladder = altitude above ground
	// Flying = altitude above ground

	private _isCarrierSector = _sector getVariable ["WL2_isAircraftCarrier", false];

	if (_isCarrierSector) then {
		getPosASL _unit # 2 > 10;
	} else {
		private _zAboveGeneric = (getPos _unit) # 2;
		_zAboveGeneric > -2 && _zAboveGeneric < 50;
	};
};

private _vehicleCapValueList = serverNamespace getVariable "WL2_cappingValues";
private _disallowManList = ["B_UAV_AI", "O_UAV_AI", "I_UAV_AI"];
private _strongholdMarker = _sector getVariable ["WL_strongholdMarker", ""];
private _sideCapValues = createHashMap;
{
	private _unit = _x;
	private _side = side group _unit;

	if (typeOf _unit in _disallowManList) then {
		continue;
	};
	private _sideModifier = _sideCaptureModifier getOrDefault [_side, 0];
	if (_sideModifier == 0) then {
		continue;
	};

	private _points = if (_unit isKindOf "Man") then {
		private _score = if (_unit inArea _strongholdMarker && vehicle _unit == _unit) then {
			5;
		} else {
			1;
		};
		_score * _sideModifier;
	} else {
		private _aliveCrew = (crew _unit) select { alive _x && !(typeOf _x in _disallowManList) };
		private _crewCount = count _aliveCrew;
		if (_crewCount > 0) then {
			private _assetActualType = _unit getVariable ["WL2_orderedClass", typeOf _unit];
			_vehicleCapValueList getOrDefault [_assetActualType, 0];
		} else {
			0;
		};
	};

	private _currentPoints = _sideCapValues getOrDefault [_side, 0];
	_sideCapValues set [_side, _currentPoints + _points];
} forEach _eligibleEntitiesInArea;

// Return format: [[side, points]...]
// Example: [[west, 5], [east, 3], [independent, 2]]
private _info = _sideArr apply {
	private _side = _x;

    private _originalOwner = _sector getVariable ["BIS_WL_owner", independent];
    private _tiebreaker = if (_side == _originalOwner) then {
        0.5;    // half point defender advantage
    } else {
        0;
    };
    private _sideScore = _sideCapValues getOrDefault [_side, 0];

	[_side, _sideScore + _tiebreaker];
};
private _sortedInfo = [_info, [], { _x # 1 }, "DESCEND"] call BIS_fnc_sortBy;
_sortedInfo;