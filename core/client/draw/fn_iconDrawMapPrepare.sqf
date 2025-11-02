#include "includes.inc"
// _drawMode: 0 = normal, 1 = spectator, 2 = stored
params [["_map", controlNull], ["_drawMode", 0]];

if (isNull _map) exitWith {};

private _controlPosition = ctrlPosition _map;
private _mapX = _controlPosition # 0;
private _mapY = _controlPosition # 1;
private _mapW = _controlPosition # 2;
private _mapH = _controlPosition # 3;
private _bottomLeftCorner = _map ctrlMapScreenToWorld [_mapX, _mapY + _mapH];
private _topRightCorner = _map ctrlMapScreenToWorld [_mapX + _mapW, _mapY];
private _mapCenter = _map ctrlMapScreenToWorld [_mapX + _mapW / 2, _mapY + _mapH / 2];
private _mapWidth = _topRightCorner # 0 - _bottomLeftCorner # 0;
private _mapHeight = _topRightCorner # 1 - _bottomLeftCorner # 1;
private _mapBoundW = _mapWidth * 0.5;
private _mapBoundH = _mapHeight * 0.5;

private _drawAll = _drawMode == 1 || _drawMode == 2;
private _draw = (ctrlMapScale _map) < 0.3 || _drawMode == 2;

private _drawIcons = [];
private _drawIconsAnimated = [];
private _drawIconsSelectable = [];
private _drawEllipses = [];
private _drawLines = [];

private _mapData = missionNamespace getVariable ["WL2_mapData", createHashMap];
private _side = _mapData getOrDefault ["side", sideUnknown];

private _mapColorCache = uiNamespace getVariable ["WL2_mapColorCache", createHashMap];
private _mapIconCache = uiNamespace getVariable ["WL2_mapIconCache", createHashMap];
private _mapTextCache = uiNamespace getVariable ["WL2_mapTextCache", createHashMap];
private _mapSizeCache = uiNamespace getVariable ["WL2_mapSizeCache", createHashMap];

private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];
private _mapIconScale = _settingsMap getOrDefault ["mapIconScale", 1];

// Draw white hover selector
if !(isNull BIS_WL_highlightedSector) then {
	_drawIconsAnimated pushBack [
		"A3\ui_f\data\map\groupicons\selector_selectedMission_ca.paa",
		[1, 1, 1, 0.5],
		getPosASL BIS_WL_highlightedSector,
		60,
		60,
		0
	];
};

// Draw vote selected marker
if !(isNull BIS_WL_targetVote) then {
	_drawIcons pushBack [
		"A3\ui_f\data\map\groupicons\selector_selectedMission_ca.paa",
		[0.8, 0.8, 0.8, 1],
		getPosASL BIS_WL_targetVote,
		60,
		60,
		0
	];
};

// Draw asset selector
if !(isNull WL_AssetActionTarget) then {
	_drawIconsAnimated pushBack [
		"A3\ui_f\data\map\groupicons\selector_selectedMission_ca.paa",
		[objNull, _mapColorCache] call WL2_fnc_iconColor,
		getPosASL WL_AssetActionTarget,
		40,
		40,
		0
	];
};

// Draw sector selector
if (!isNull WL_SectorActionTarget && isNull BIS_WL_highlightedSector && WL_SectorActionTargetActive) then {
	_drawIconsAnimated pushBack [
		"A3\ui_f\data\map\groupicons\selector_selectedMission_ca.paa",
		[objNull, _mapColorCache] call WL2_fnc_iconColor,
		getPosASL WL_SectorActionTarget,
		50,
		50,
		0
	];
};

// Draw waypoints
private _currentGroup = group cameraOn;
private _currentPosition = getPosASL cameraOn;
{
	private _waypointPosition = waypointPosition _x;
	private _currentWaypointIndex = currentWaypoint _currentGroup;

	if (_forEachIndex < _currentWaypointIndex) then {
		continue;
	};

	_drawIcons pushBack [
		"a3\ui_f\data\map\mapcontrol\waypointeditor_ca.paa",
		[1, 1, 0, 1],
		_waypointPosition,
		20 * _mapIconScale,
		20 * _mapIconScale,
		0,
		str (_forEachIndex - _currentWaypointIndex + 1),
		0,
		0.05 * _mapIconScale,
		"PuristaBold"
	];

	_drawLines pushBack [
		_currentPosition,
		_waypointPosition,
		[0.9, 0.9, 0.9, 1],
		8
	];

	_currentPosition = _waypointPosition;
} forEach (waypoints _currentGroup);

// Draw player tent
private _respawnBag = player getVariable ["WL2_respawnBag", objNull];
if (alive _respawnBag) then {
	private _bagPos = getPosATL _respawnBag;
	_drawIcons pushBack [
		"\A3\ui_f\data\map\markers\military\triangle_CA.paa",
		[1, 1, 0, 1],
		_bagPos,
		35 * _mapIconScale,
		35 * _mapIconScale,
		0,
		"Tent",
		1,
		0.04 * _mapIconScale,
		"PuristaBold"
	];
	_drawIconsSelectable pushBack [_respawnBag, _bagPos];
};

// Draw forward bases
private _forwardBases = missionNamespace getVariable ["WL2_forwardBases", []];
{
	private _base = _x;
	private _position = getPosATL _base;

	private _baseOwner = _base getVariable ["WL2_forwardBaseOwner", sideUnknown];
	private _showOnMap = _base getVariable ["WL2_forwardBaseShowOnMap", false];
	if (_baseOwner != _side && !_drawAll && !_showOnMap) then {
		continue;
	};

	private _baseColor = switch (_baseOwner) do {
		case west: { [0, 0.3, 0.6, 0.9] };
		case east: { [0.5, 0, 0, 0.9] };
		case independent: { [0, 0.6, 0, 0.9] };
		default { [1, 1, 1, 0] };
	};

	private _intruders = _base getVariable ["WL2_forwardBaseIntruders", false];
	private _fillTexture = if (_intruders) then {
		"#(rgb,1,1,1)color(1,1,1,0.3)"
	} else {
		""
	};

	private _baseTime = _base getVariable ["WL2_forwardBaseTime", -1];

	private _baseText = if (serverTime < _baseTime) then {
		private _timeRemaining = _baseTime - serverTime;
		private _timeString = [_timeRemaining, "MM:SS"] call BIS_fnc_secondsToString;
		format ["(Constructing %1)", _timeString];
	} else {
		private _maxHealth = _base getVariable ["WL2_demolitionMaxHealth", 5];
		private _fobHealth = _base getVariable ["WL2_demolitionHealth", _maxHealth];
		if (_baseOwner == _side) then {
			private _supplies = _base getVariable ["WL2_forwardBaseSupplies", -1];
			_supplies = (round _supplies) max 0;
			format ["(%1/%2) [%3 Supplies]", _fobHealth, _maxHealth, (_supplies call BIS_fnc_numberText) regexReplace [" ", ","]];
		} else {
			format ["(%1/%2)", _fobHealth, _maxHealth];
		};
	};

	_drawIcons pushBack [
		"\A3\Ui_f\data\IGUI\Cfg\HoldActions\holdAction_requestLeadership_ca.paa",
		_baseColor,
		_position,
		40 * _mapIconScale,
		40 * _mapIconScale,
		0,
		format ["Forward Base %1", _baseText],
		0,
		0.045 * _mapIconScale
	];
	_drawIconsSelectable pushBack [_base, _position];

	_drawEllipses pushBack [
		_position,
		WL_FOB_RANGE,
		WL_FOB_RANGE,
		0,
		_baseColor,
		_fillTexture
	];
	if (WL_AssetActionTarget == _base) then {
		_drawEllipses pushBack [
			_position,
			WL_FOB_MIN_DISTANCE,
			WL_FOB_MIN_DISTANCE,
			0,
			_baseColor,
			""
		];
	};

	private _sectorsInRange = _x getVariable ["WL2_forwardBaseSectors", []];
	{
		private _sectorPos = getPosASL _x;

		private _startPointDirection = _base getRelDir _sectorPos;
		private _startPoint = _base getRelPos [100, _startPointDirection];

		private _endPointDirection = _x getRelDir _position;
		private _endPoint = _x getRelPos [100, _endPointDirection];

		_drawLines pushBack [
			_startPoint,
			_endPoint,
			_baseColor,
			8
		];
	} forEach _sectorsInRange;
} forEach _forwardBases;

private _fobSupplies = _mapData getOrDefault ["fobSupplies", []];
{
	if (WL_AssetActionTarget != _x) then {
		continue;
	};
	_drawEllipses pushBack [
		getPosASL _x,
		WL_FOB_CAPTURE_RANGE,
		WL_FOB_CAPTURE_RANGE,
		0,
		[_x, _mapColorCache] call WL2_fnc_iconColor,
		""
	];
} forEach _fobSupplies;

// Draw strongholds
private _strongholds = missionNamespace getVariable ["WL_strongholds", []];
{
	private _stronghold = _x;

	private _strongholdPos = getPosATL _stronghold;
	private _intruders = _stronghold getVariable ["WL2_strongholdIntruders", false];
	private _strongholdColor = if (_intruders) then {
		[1, 0, 0, 1]
	} else {
		[1, 1, 1, 1]
	};

	private _maxHealth = _stronghold getVariable ["WL2_demolitionMaxHealth", 5];
	private _strongholdHealth = _stronghold getVariable ["WL2_demolitionHealth", _maxHealth];
	_drawIcons pushBack [
		"\A3\ui_f\data\map\mapcontrol\Ruin_CA.paa",
		_strongholdColor,
		_strongholdPos,
		20 * _mapIconScale,
		20 * _mapIconScale,
		0,
		if (_draw) then { format ["  STRONGHOLD (%1/%2)", _strongholdHealth, _maxHealth] } else {""},
		1,
		0.043,
		"PuristaBold",
		"right"
	];

	private _strongholdRadius = _stronghold getVariable ["WL_strongholdRadius", 0];

	_drawEllipses pushBack [
		_strongholdPos,
		_strongholdRadius,
		_strongholdRadius,
		0,
		[1, 1, 1, 1],
		"#(rgb,8,8,3)color(1,1,1,0.2)"
	];

	_drawIconsSelectable pushBack [_stronghold, _strongholdPos];
} forEach _strongholds;

// Draw scanned units
private _scannedUnits = _mapData getOrDefault ["scannedUnits", []];
{
	private _position = getPosASL _x;
	private _size = [_x, _mapSizeCache] call WL2_fnc_iconSize;
	private _textSize = if (_x isKindOf "Man") then { 0.025 } else { 0.043 };
	_drawIcons pushBack [
		[_x, _mapIconCache] call WL2_fnc_iconType,
		[_x, _mapColorCache] call WL2_fnc_iconColor,
		_position,
		_size * _mapIconScale,
		_size * _mapIconScale,
		[_x] call WL2_fnc_getDir,
		[_x, _draw, false, _mapTextCache] call WL2_fnc_iconText,
		1,
		_textSize * _mapIconScale,
		"PuristaBold",
		"right"
	];
} forEach (_scannedUnits inAreaArray [_mapCenter, _mapBoundW, _mapBoundH, 0, true]);

// Draw EW networks
{
	if (isNull _x) then { continue; };

	private _position = getPosASL _x;

	private _range = _x getVariable ["WL_ewNetRange", 0];
	_drawEllipses pushBack [
		_position,
		_range,
		_range,
		0,
		[_x, _mapColorCache] call WL2_fnc_iconColor,
		""
	];
} forEach (_mapData getOrDefault ["ewNetworks", []]);

// Draw scanner
private _assetData = WL_ASSET_DATA;
private _scale = 6.4 * worldSize / 8192 * ctrlMapScale _map;

private _scanners = if (_drawAll) then {
	_mapData getOrDefault ["scannersAll", []]
} else {
	_mapData getOrDefault ["scannersTeam", []]
};
{
	if (isNull _x) then { continue; };

	private _position = getPosASL _x;

    private _scanRadius = _x getVariable ["WL_scanRadius", 100];
	if (_scanRadius == 0) then { continue; };
    private _assetActualType = _x getVariable ["WL2_orderedClass", typeOf _x];
	private _isAWACS = WL_ASSET_FIELD(_assetData, _assetActualType, "hasAWACS", 0) > 0;
	if (_isAWACS) then {
		private _size = _scanRadius / _scale;
		_drawIcons pushBack [
			"\a3\ui_f\data\IGUI\RscCustomInfo\Sensors\Sectors\sector60_ca.paa",
			[1, 1, 1, 0.3],
			_position,
			_size,
			_size,
			getDirVisual _x
		];
	} else {
		private _isNotThreatDetector = WL_ASSET_FIELD(_assetData, _assetActualType, "threatDetection", 0) == 0;
		if (_isNotThreatDetector) then {
			_drawEllipses pushBack [
				_position,
				_scanRadius,
				_scanRadius,
				0,
				[0, 1, 1, 1],
				"#(rgb,1,1,1)color(0,1,1,0.15)"
			];
		};
	};
} forEach _scanners;

// Draw squad lines
private _allSquadmates = _mapData getOrDefault ["allSquadmates", []];
if (WL_AssetActionTarget in _allSquadmates) then {
	private _squadLeader = _allSquadmates select {
		["isSquadLeader", [getPlayerID _x]] call SQD_fnc_client;
	};

	if (count _squadLeader > 0) then {
		_squadLeader = _squadLeader # 0;
		_allSquadmates = _allSquadmates - [_squadLeader];
		{
			_drawLines pushBack [
				getPosASL _squadLeader,
				getPosASL _x,
				[0, 1, 1, 0.8],
				6
			];
		} forEach _allSquadmates;
	};
};

// Draw vehicles
private _sideVehicles = if (_drawAll) then {
	_mapData getOrDefault ["sideVehiclesAll", []]
} else {
	_mapData getOrDefault ["sideVehicles", []]
};

{
	private _position = getPosASL _x;

	private _threatDetector = _x getVariable ["DIS_missileDetector", 0];
	if (_threatDetector > 0) then {
		_drawEllipses pushBack [
			_position,
			_threatDetector,
			_threatDetector,
			0,
			[_x, _mapColorCache] call WL2_fnc_iconColor,
			""
		];
	};

	private _size = [_x, _mapSizeCache] call WL2_fnc_iconSize;
	_drawIcons pushBack [
		[_x, _mapIconCache] call WL2_fnc_iconType,
		[_x, _mapColorCache] call WL2_fnc_iconColor,
		_position,
		_size * _mapIconScale,
		_size * _mapIconScale,
		[_x] call WL2_fnc_getDir,
		[_x, _draw, true, _mapTextCache] call WL2_fnc_iconText,
		1,
		0.043 * _mapIconScale,
		"PuristaBold",
		"right"
	];
	_drawIconsSelectable pushBack [_x, _position];
} forEach (_sideVehicles inAreaArray [_mapCenter, _mapBoundW, _mapBoundH, 0, true]);

private _advancedSams = _mapData getOrDefault ["advancedSams", []];
{
	private _position = getPosASL _x;

	private _detectionLocation = _x getVariable ["DIS_advancedSamDetectionLocation", []];
	if (count _detectionLocation != 3) then { continue; };
	_drawIcons pushBack [
		"\A3\ui_f\data\map\markers\handdrawn\warning_CA.paa",
		[1, 0, 0, 1],
		_detectionLocation,
		40 * _mapIconScale,
		40 * _mapIconScale,
		0,
		"ENEMY HEAVY SAM",
		1,
		0.08 * _mapIconScale,
		"PuristaBold",
		"right"
	];
} forEach _advancedSams;

private _drawSectorMarkerThreshold = _mapData getOrDefault ["sectorMarkerThreshold", 0.4];
private _drawSectorMarkerText = (ctrlMapScale _map) < _drawSectorMarkerThreshold;

private _sectorMarkers = _mapData getOrDefault ["teamSectorMarkers", []];
{
	private _marker = [_x, BIS_WL_playerSide] call WL2_fnc_drawSectorMarker;
	_drawIcons pushBack _marker;
} forEach _sectorMarkers;

if (_drawAll) then {
	private _enemySectorMarkers = _mapData getOrDefault ["enemySectorMarkers", []];
	{
		private _marker = [_x, BIS_WL_enemySide] call WL2_fnc_drawSectorMarker;
		_drawIcons pushBack _marker;
	} forEach _enemySectorMarkers;
};

// Spectator draw
if (_drawAll) then {
	private _camera = cameraOn;
	if (!isNull _camera && WL_IsSpectator) then {
		private _center = _camera screenToWorld [0.5, 0.5];
		private _distance = if (_center isEqualTo [0, 0, 0]) then {
			viewDistance;
		} else {
			_camera distance2D _center;
		};

		_drawIcons pushBack [
			"a3\Ui_f\data\GUI\Rsc\RscDisplayEGSpectator\cameraTexture_ca.paa",
			[1, 1, 1, 1],
			getPosASL _camera,
			40,
			50,
			getDirVisual _camera
		];
		private _cameraPos = getPosASL _camera;
		private _angle = 30;
		private _sideDistance = _distance / cos _angle;
		private _sideA = _camera getRelPos [_sideDistance, _angle];
		private _sideB = _camera getRelPos [_sideDistance, -_angle];

		_drawLines pushBack [
			_cameraPos,
			_sideA,
			[1, 1, 1, 1],
			10
		];
		_drawLines pushBack [
			_cameraPos,
			_sideB,
			[1, 1, 1, 1],
			10
		];
		_drawLines pushBack [
			_sideA,
			_sideB,
			[1, 1, 1, 1],
			10
		];
	};
};

private _drawSectorIcons = [];
if (_drawMode == 2) then {
	{
		private _sectorName = _x getVariable ["WL2_name", ""];
		private _sectorPos = getPosASL _x;
		private _sectorOwner = _x getVariable ["BIS_WL_owner", independent];
		private _sectorColor = switch (_sectorOwner) do {
			case west: { [0, 0.3, 0.6, 0.9] };
			case east: { [0.5, 0, 0, 0.9] };
			case independent: { [0, 0.6, 0, 0.9] };
			default { [1, 1, 1, 1] };
		};
		private _sectorIcon = switch (_sectorOwner) do {
			case west: { "\A3\ui_f\data\map\markers\nato\b_installation.paa" };
			case east: { "\A3\ui_f\data\map\markers\nato\o_installation.paa" };
			case independent: { "\A3\ui_f\data\map\markers\nato\n_installation.paa" };
			default { "" };
		};
		_drawSectorIcons pushBack [
			_sectorIcon,
			_sectorColor,
			_sectorPos,
			20,
			20,
			0,
			_sectorName,
			1,
			0.05,
			"PuristaBold",
			"right"
		];
	} forEach BIS_WL_allSectors;
};

if (_drawMode == 2) then {
	private _storedDrawIcons = missionNamespace getVariable ["WL2_drawIcons", []];
	private _storedDrawEllipses = missionNamespace getVariable ["WL2_drawEllipses", []];
	private _storedSectorIcons = missionNamespace getVariable ["WL2_drawSectorIcons", []];

	_storedDrawIcons pushBack _drawIcons;
	_storedDrawEllipses pushBack _drawEllipses;
	_storedSectorIcons pushBack _drawSectorIcons;
} else {
	uiNamespace setVariable ["WL2_drawIcons", _drawIcons];
	uiNamespace setVariable ["WL2_drawIconsAnimated", _drawIconsAnimated];
	uiNamespace setVariable ["WL2_drawIconsSelectable", _drawIconsSelectable];
	uiNamespace setVariable ["WL2_drawEllipses", _drawEllipses];
	uiNamespace setVariable ["WL2_drawLines", _drawLines];
};

uiNamespace setVariable ["WL2_mapColorCache", _mapColorCache];
uiNamespace setVariable ["WL2_mapIconCache", _mapIconCache];
uiNamespace setVariable ["WL2_mapTextCache", _mapTextCache];
uiNamespace setVariable ["WL2_mapSizeCache", _mapSizeCache];