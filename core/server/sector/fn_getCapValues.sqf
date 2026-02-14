#include "includes.inc"
params ["_sector"];

private _ownerSide = _sector getVariable ["BIS_WL_owner", independent];

private _westArea = missionNamespace getVariable ["WL2_westControlledArea", 0];
private _eastArea = missionNamespace getVariable ["WL2_eastControlledArea", 0];
_westArea = _westArea max 1;
_eastArea = _eastArea max 1;
private _westAreaRatio = _westArea / (_westArea + _eastArea);
private _eastAreaRatio = 1 - _westAreaRatio;
private _westMod = _westAreaRatio * 2;
private _eastMod = _eastAreaRatio * 2;
private _modifiers = [_westMod, _eastMod, 0];

private _sideArr = [west, east, independent];
private _sideCaptureModifier = createHashMap;
{
	private _side = _x;

	if (_side == independent) then {
		private _reserves = _sector getVariable ["WL2_sectorPop", 0];
		if (_reserves > 0) then {
			_sideCaptureModifier set [_side, 3];
		} else {
			_sideCaptureModifier set [_side, 2];
		};
		continue;
	};

	private _sideLinkedSectors = BIS_WL_sectorsArrays # (BIS_WL_competingSides find _side) # 2;
	private _neighboringSectors = synchronizedObjects _sector;
	private _connectedNeighboringSectors = _neighboringSectors select {
		typeof _x == "Logic" && _side == _x getVariable ["BIS_WL_owner", independent] && _x in _sideLinkedSectors;
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
		_sector distance2D _x < WL_FOB_CAPTURE_RANGE
	} select {
		_x getVariable ["WL2_forwardBaseReady", false]
	};
	_connections = _connections + (count _inRangeTeamForwardBases) * WL_FOB_CAPMODIFIER;

	private _sideModifier = _modifiers # _forEachIndex;
	_connections = _connections + _sideModifier;

	_sideCaptureModifier set [_side, _connections];
} forEach _sideArr;

private _relevantEntities = entities [["LandVehicle", "Man"], ["Logic"], true, true];
private _sectorAO = _sector getVariable "objectAreaComplete";
private _allInArea = (_relevantEntities inAreaArray _sectorAO) select {
	WL_ISUP(_x)
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

private _assetData = WL_ASSET_DATA;
private _disallowManList = ["B_UAV_AI", "O_UAV_AI", "I_UAV_AI"];
private _stronghold = _sector getVariable ["WL_stronghold", objNull];
private _strongholdRadius = _stronghold getVariable ["WL_strongholdRadius", 0];

private _sideCapValues = createHashMap;
{
	private _unit = _x;
	private _side = side group _unit;

	if (typeOf _unit in _disallowManList) then {
		continue;
	};

	private _points = if (_unit isKindOf "Man") then {
		if (_ownerSide != independent && _unit distance2D _stronghold < _strongholdRadius && vehicle _unit == _unit) then {
			7;
		} else {
			1;
		};
	} else {
		private _aliveCrew = (crew _unit) select { WL_ISUP(_x) && !(typeOf _x in _disallowManList) };
		private _crewCount = count _aliveCrew;
		if (_crewCount > 0) then {
			private _assetActualType = WL_ASSET_TYPE(_unit);
			WL_ASSET_FIELD(_assetData, _assetActualType, "capValue", 0);
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

    private _tiebreaker = if (_side == _ownerSide) then {
        0.5;    // half point defender advantage
    } else {
        0;
    };
    private _sideScore = _sideCapValues getOrDefault [_side, 0];

	private _modifier = _sideCaptureModifier getOrDefault [_side, 0];

	[_side, _sideScore * _modifier + _tiebreaker, _modifier];
};
private _sortedInfo = [_info, [], { _x # 1 }, "DESCEND"] call BIS_fnc_sortBy;
_sortedInfo;