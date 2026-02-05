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
private _drawIconsFollowMouse = [];
private _drawEllipses = [];
private _drawSemiCircles = [];
private _drawLines = [];
private _drawRectangles = [];
private _drawPolygons = [];

private _mapData = missionNamespace getVariable ["WL2_mapData", createHashMap];
private _side = _mapData getOrDefault ["side", sideUnknown];

private _mapColorCache = uiNamespace getVariable ["WL2_mapColorCache", createHashMap];
private _mapIconCache = uiNamespace getVariable ["WL2_mapIconCache", createHashMap];
private _mapTextCache = uiNamespace getVariable ["WL2_mapTextCache", createHashMap];
private _mapSizeCache = uiNamespace getVariable ["WL2_mapSizeCache", createHashMap];

private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];
private _mapIconScale = _settingsMap getOrDefault ["mapIconScale", 1];

// Draw sector links
private _sectorTarget = WL_SectorActionTarget;
private _allLinks = missionNamespace getVariable ["WL2_linkSectorMarkers", createHashMap];
private _mapSectorLineGrayscale = _settingsMap getOrDefault ["mapSectorLineGrayscale", 1];
private _neutralLinkColor = [_mapSectorLineGrayscale, _mapSectorLineGrayscale, _mapSectorLineGrayscale, 1];
private _ownedSectorLinkColor = if (BIS_WL_playerSide == west) then {
	[0, 0.3, 0.6, 1]
} else {
	[0.5, 0, 0, 1]
};

private _sectorsInLinksShown = [];
if (BIS_WL_selection_showLinks) then {
	{
		private _pairKey = _x;
		private _linkData = _y;
		_y params ["_startPos", "_endPos", "_sector", "_link"];
		private _sectorOwner = _sector getVariable ["BIS_WL_owner", sideUnknown];
		private _linkOwner = _link getVariable ["BIS_WL_owner", sideUnknown];
		private _linkColor = if (_sectorOwner == BIS_WL_playerSide && _linkOwner == BIS_WL_playerSide) then {
			_ownedSectorLinkColor;
		} else {
			_neutralLinkColor;
		};

		_drawLines pushBack [
			_startPos,
			_endPos,
			_linkColor,
			10
		];
	} forEach _allLinks
} else {
	private _sectorLineSpeed = _settingsMap getOrDefault ["mapSectorLineSpeed", 0.25];
	private _sectorLineMax = _settingsMap getOrDefault ["mapSectorLineMax", 1];
	_sectorLineMax = _sectorLineMax - 1;

	if (!isNull _sectorTarget) then {
		private _links = [_sectorTarget];
		private _lastDrawnLinks = uiNamespace getVariable ["WL2_mapLastDrawnLinks", false];
		if (!_lastDrawnLinks) then {
			uiNamespace setVariable ["WL2_firstDrawLinkTime", serverTime];
			uiNamespace setVariable ["WL2_mapLastDrawnLinks", true];
		};
		private _firstDrawLinkTime = uiNamespace getVariable ["WL2_firstDrawLinkTime", serverTime];
		private _linksToShow = if (_sectorLineSpeed > 0) then {
			(serverTime - _firstDrawLinkTime) / _sectorLineSpeed;
		} else {
			_sectorLineMax
		};
		_linksToShow = _linksToShow min _sectorLineMax;
		for "_i" from 0 to _linksToShow do {
			private _allConnections = [];
			{
				private _connections = _x getVariable ["WL2_connectedSectors", []];
				_allConnections insert [-1, _connections, true];
			} forEach _links;
			_links insert [-1, _allConnections, true];
		};

		_sectorsInLinksShown = _links;

		private _drawnLinks = createHashMap;
		{
			private _pairKey = _x;
			private _linkData = _y;
			_y params ["_startPos", "_endPos", "_sector", "_link"];

			if !(_sector in _links) then {
				continue;
			};
			if !(_link in _links) then {
				continue;
			};
			if (_pairKey in _drawnLinks) then {
				continue;
			};
			if (_linksToShow == 0) then {
				if (_sector != _sectorTarget && _link != _sectorTarget) then {
					continue;
				};
			};

			private _sectorOwner = _sector getVariable ["BIS_WL_owner", sideUnknown];
			private _linkOwner = _link getVariable ["BIS_WL_owner", sideUnknown];
			private _linkColor = if (_sectorOwner == BIS_WL_playerSide && _linkOwner == BIS_WL_playerSide) then {
				_ownedSectorLinkColor;
			} else {
				_neutralLinkColor;
			};

			_drawLines pushBack [
				_startPos,
				_endPos,
				_linkColor,
				10
			];
			_drawnLinks set [_pairKey, true];
		} forEach _allLinks;
	} else {
		uiNamespace setVariable ["WL2_mapLastDrawnLinks", false];
	};
};

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

if (BIS_WL_currentSelection == WL_ID_SELECTION_ORDERING_NAVAL) then {
	// All sectors within 1.5km
	private _mousePosition = getMousePosition;
	private _mouseWorldPosition = _map ctrlMapScreenToWorld _mousePosition;

	private _waterDropCost = uiNamespace getVariable ["WL2_waterDropCost", -1];
	if (_waterDropCost >= 1000) then {
		private _forwardBases = missionNamespace getVariable ["WL2_forwardBases", []];
		private _spawnLocations = _forwardBases select {
			_x getVariable ["WL2_forwardBaseOwner", sideUnknown] == BIS_WL_playerSide
		};
		_spawnLocations append (BIS_WL_sectorsArray # 0);

		private _ownedSectorsInRange = _spawnLocations select {
			_mouseWorldPosition distance _x < 1500;
		};
		{
			_drawEllipses pushBack [
				getPosASL _x,
				1500,
				1500,
				0,
				[1, 1, 1, 1],
				""
			];
		} forEach _ownedSectorsInRange;
	};

	_drawEllipses pushBack [
		getPosASL player,
		200,
		200,
		0,
		[1, 1, 1, 1],
		""
	];
};

// Draw asset selector
private _assetTargets = WL_AssetActionTargets;
if (count _assetTargets > 0) then {
	private _color = [objNull, _mapColorCache] call WL2_fnc_iconColor;
	{
		_drawIconsAnimated pushBack [
			"A3\ui_f\data\map\groupicons\selector_selectedMission_ca.paa",
			_color,
			getPosASL _x,
			40,
			40,
			0
		];

		private _mapCircleRadius = _x getVariable ["WL2_mapCircleRadius", 0];
		if (_mapCircleRadius > 0) then {
			_drawEllipses pushBack [
				getPosASL _x,
				_mapCircleRadius,
				_mapCircleRadius,
				0,
				_color,
				""
			];
		};
	} forEach _assetTargets;
};

// Draw sector selector
if (!isNull _sectorTarget) then {
	private _sectorPos = getPosASL _sectorTarget;
	if (isNull BIS_WL_highlightedSector && WL_SectorActionTargetActive) then {
		_drawIcons pushBack [
			"A3\ui_f\data\map\groupicons\selector_selectedMission_ca.paa",
			[objNull, _mapColorCache] call WL2_fnc_iconColor,
			_sectorPos,
			50,
			50,
			0
		];
	};

	private _sectorInfo = _sectorTarget getVariable ["WL2_sectorInfo", []];
	private _spacing = 0;
	{
		private _textSize = if (_forEachIndex == 0) then {
			0.1 * _mapIconScale
		} else {
			0.08 * _mapIconScale
		};
		private _spacingAdd = if (_forEachIndex <= 1) then {
			0.05
		} else {
			0.04
		};
		_spacing = _spacing + _spacingAdd;

		if (_x isEqualType []) then {
			private _text = _x # 0;
			private _color = _x # 1;

			_drawIconsFollowMouse pushBack [
				"#(rgb,1,1,1)color(1,1,1,1)",
				_color,
				[0.03, _spacing],
				0,
				0,
				0,
				_text,
				2,
				_textSize,
				"PuristaSemibold",
				"right"
			];
		} else {
			_drawIconsFollowMouse pushBack [
				"#(rgb,1,1,1)color(1,1,1,1)",
				[1, 1, 1, 1],
				[0.03, _spacing],
				0,
				0,
				0,
				_x,
				2,
				_textSize,
				"PuristaSemibold",
				"right"
			];
		};
	} forEach _sectorInfo;
};

// Draw sector areas
if (!isNull _sectorTarget || BIS_WL_selection_showLinks) then {
	private _facesData = missionNamespace getVariable ["WL2_sectorFaces", []];

	private _neutralRGBA = [0.2, 0.2, 0.2, 0.3];
	private _sideColorRGBA = switch (BIS_WL_playerSide) do {
		case west: { [0, 0.3, 0.6, 0.4] };
		case east: { [0.5, 0, 0, 0.4] };
		case independent: { _neutralRGBA };
		default { _neutralRGBA };
	};

	private _shouldShowFace = {
		params ["_sectors"];

		if (BIS_WL_selection_showLinks) exitWith { true };

		private _intersections = _sectorsInLinksShown arrayIntersect _sectors;
		private _showFace = count _intersections == count _sectors;

		if (_showFace) exitWith { true };

		_sectorTarget in _sectors;
	};

	{
		_x params ["_sectors", "_area"];

		if !([_sectors] call _shouldShowFace) then {
			continue;
		};

		private _ownsFace = true;
		{
			private _sectorOwner = _x getVariable ["BIS_WL_owner", sideUnknown];
			if (_sectorOwner != BIS_WL_playerSide) then {
				_ownsFace = false;
				break;
			};
		} forEach _sectors;

		private _location = [0, 0, 0];
		{
			_location = _location vectorAdd (getPosASL _x);
		} forEach _sectors;
		_location = _location vectorMultiply (1 / count _sectors);

		private _income = round (_area * WL_INCOME_M2);
		private _incomeText = if (_ownsFace) then {
			format ["+%1", _income]
		} else {
			private _vertices = count _sectors;
			private _bonus = _income * WL_INCOME_CAPBONUS * _vertices;
			private _bonusText = if (_bonus >= 1000) then {
				private _bonusK = floor (_bonus / 1000);
				private _bonusR = _bonus mod 1000;
				_bonusR = if (_bonusR >= 100) then {
					format ["%1", _bonusR]
				} else {
					if (_bonusR >= 10) then {
						format ["0%1", _bonusR]
					} else {
						format ["00%1", _bonusR]
					};
				};
				format ["%1,%2", _bonusK, _bonusR]
			} else {
				format ["%1", _bonus]
			};
			format ["%1 (+%2)", _bonusText, _income]
		};

		_drawIcons pushBack [
			"#(rgb,1,1,1)color(1,1,1,1)",
			[1, 1, 1, 1],
			_location,
			0,
			0,
			0,
			_incomeText,
			1,
			0.06 * _mapIconScale,
			"PuristaSemibold",
			"center"
		];

		private _sectorDrawPoints = _sectors apply {
			getPosASL _x;
		};

		private _colorToUse = if (_ownsFace) then {
			_sideColorRGBA
		} else {
			_neutralRGBA
		};
		_drawPolygons pushBack [
			_sectorDrawPoints,
			_colorToUse,
			"#(rgb,1,1,1)color(1,1,1,1)"
		];
	} forEach _facesData;
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
} forEach (_mapData getOrDefault ["uavWaypoints", []]);

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

	private _baseReady = _base getVariable ["WL2_forwardBaseReady", false];

	private _baseText = if (!_baseReady) then {
		"(Under Construction)";
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

	private _isLocked = _base getVariable ["WL2_forwardBaseLocked", false];
	private _baseIcon = if (_isLocked) then {
		"a3\modules_f\data\iconlock_ca.paa"
	} else {
		"\A3\Ui_f\data\IGUI\Cfg\HoldActions\holdAction_requestLeadership_ca.paa"
	};
	private _baseIconSize = if (_isLocked) then { 25 * _mapIconScale } else { 40 * _mapIconScale };

	private _defenseLevel = _base getVariable ["WL2_forwardBaseDefenseLevel", 0];
	private _baseTypeText = switch (_defenseLevel) do {
		case 0: { "Forward Base" };
		case 1: { "Forward Base 1/4" };
		case 2: { "Forward Base 2/4" };
		case 3: { "Forward Base 3/4" };
		case 4: { "Forward Airbase" };
		default { "Forward Base" };
	};

	_drawIcons pushBack [
		_baseIcon,
		_baseColor,
		_position,
		_baseIconSize,
		_baseIconSize,
		0,
		format ["%1 %2", _baseTypeText, _baseText],
		0,
		0.045 * _mapIconScale
	];
	_drawIconsSelectable pushBack _base;

	_drawEllipses pushBack [
		_position,
		WL_FOB_RANGE,
		WL_FOB_RANGE,
		0,
		_baseColor,
		_fillTexture
	];

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

private _rallyPoints = _mapData getOrDefault ["rallyPoints", []];
{
	private _rallyPointSide = [_x] call WL2_fnc_getAssetSide;
	if (_rallyPointSide != _side && !_drawAll && cameraOn distance2D _x > 500) then {
		continue;
	};

	private _boundingBox = boundingBoxReal _x;

	private _xLength = (_boundingBox # 1 # 0) - (_boundingBox # 0 # 0);
	private _yLength = (_boundingBox # 1 # 1) - (_boundingBox # 0 # 1);

	_drawRectangles pushBack [
		getPosASL _x,
		_xLength / 2,
		_yLength / 2,
		getDir _x,
		[1, 1, 1, 1],
		"#(rgb,1,1,1)color(0,0,1,0.2)"
	];
} forEach _rallyPoints;

// Draw strongholds
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

	_drawIconsSelectable pushBack _stronghold;
} forEach (_mapData getOrDefault ["strongholds", []]);

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
	private _hasAirRadar = WL_ASSET_FIELD(_assetData, _assetActualType, "hasAirRadar", 0) > 0;
	if (_hasAirRadar) then {
		if (cameraOn == _x || _x in _assetTargets) then {
			_drawSemiCircles pushBack [
				60,
				[1, 1, 1, 0.3],
				_position,
				_scanRadius,
				getDirVisual _x,
				true
			];
		};
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

// Combat air patrol areas
private _combatAirAreas = _mapData getOrDefault ["combatAirAreas", []];
{
	private _targetPos = getPosASL _x;
	private _targetOwner = if (typeof _x == "RuggedTerminal_01_communications_hub_F") then {
		_x getVariable ["WL2_forwardBaseOwner", independent];
	} else {
		_x getVariable ["BIS_WL_owner", independent];
	};

	private _mapColor = switch (_targetOwner) do {
		case west: { [0, 0.3, 0.6, 0.9] };
		case east: { [0.5, 0, 0, 0.9] };
		case independent: { [0, 0.6, 0, 0.9] };
		default { [1, 1, 1, 0.15] };
	};
	private _mapTexture = switch (_targetOwner) do {
		case west: { "#(rgb,1,1,1)color(0,0,1,0.15)" };
		case east: { "#(rgb,1,1,1)color(1,0,0,0.15)" };
		case independent: { "#(rgb,1,1,1)color(0,1,0,0.15)" };
		default { "#(rgb,1,1,1)color(1,0,1,0.15)" };
	};

	_drawEllipses pushBack [
		_targetPos,
		WL_COMBAT_AIR_RADIUS,
		WL_COMBAT_AIR_RADIUS,
		0,
		_mapColor,
		_mapTexture
	];
} forEach _combatAirAreas;

// Draw squad lines
private _allSquadmates = _mapData getOrDefault ["allSquadmates", []];
if (count (_assetTargets arrayIntersect _allSquadmates) > 0) then {
	private _squadLeader = _allSquadmates select {
		["isSquadLeader", [getPlayerID _x]] call SQD_fnc_query;
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

private _mapIconTextScale = _settingsMap getOrDefault ["mapIconTextScale", 1];
private _iconTextSize = _mapIconTextScale * 0.043;

// Draw vehicles
private _sideVehicles = _mapData getOrDefault ["sideVehicles", []];
{
	private _position = getPosASL _x;
	private _size = [_x, _mapSizeCache] call WL2_fnc_iconSize;
	private _hideMap = _x getVariable ["WL2_hideMap", 0];
	if (_hideMap == 2) then {
		continue;
	};
	private _showName = _hideMap == 0 && _draw;
	_drawIcons pushBack [
		[_x, _mapIconCache] call WL2_fnc_iconType,
		[_x, _mapColorCache] call WL2_fnc_iconColor,
		_position,
		_size * _mapIconScale,
		_size * _mapIconScale,
		[_x] call WL2_fnc_getDir,
		[_x, _showName, true, _mapTextCache] call WL2_fnc_iconText,
		1,
		_iconTextSize * _mapIconScale,
		"PuristaBold",
		"right"
	];
	_drawIconsSelectable pushBack _x;
} forEach (_sideVehicles inAreaArray [_mapCenter, _mapBoundW, _mapBoundH, 0, true]);

// Draw plane wrecks
private _airWrecks = _mapData getOrDefault ["airWrecks", []];
{
	private _position = getPosASL _x;
	private _size = [_x, _mapSizeCache] call WL2_fnc_iconSize;
	private _assetTypeName = [_x] call WL2_fnc_getAssetTypeName;
	_drawIcons pushBack [
		"\a3\Ui_F_Curator\Data\CfgMarkers\kia_ca.paa",
		[0, 0, 0, 1],
		_position,
		_size * _mapIconScale,
		_size * _mapIconScale,
		0,
		format ["%1 (Wreck)", _assetTypeName],
		1,
		_iconTextSize * _mapIconScale,
		"PuristaBold",
		"right"
	];
} forEach (_airWrecks inAreaArray [_mapCenter, _mapBoundW, _mapBoundH, 0, true]);

// Draw advanced SAMs
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

private _advancedMines = _mapData getOrDefault ["advancedMines", []];
{
	private _ownsMine = (_x getVariable ["BIS_WL_ownerAsset", "123"]) == getPlayerUID player;
	if !(_ownsMine || _x in _assetTargets) then {
		continue;
	};

	private _position = getPosASL _x;
	private _smartMineDistanceIndex = _x getVariable ["WL2_smartMineDistance", 0];
	private _detonationDistance = WL_SMART_MINE_DISTANCES # _smartMineDistanceIndex;
    private _angle = WL_SMART_MINE_ANGLES # _smartMineDistanceIndex;

	private _iconPos = _x modelToWorld [0, _detonationDistance / 2, 0];
	private _smartMinesAP = _x getVariable ["WL2_smartMinesAP", 0];
	private _smartMinesAT = _x getVariable ["WL2_smartMinesAT", 0];
	private _smartMines = format ["AP: %1 | AT: %2", _smartMinesAP, _smartMinesAT];

	_drawIcons pushBack [
		"a3\ui_f_curator\data\cfgmarkers\minefieldap_ca.paa",
		[1, 0, 0, 1],
		_iconPos,
		30 * _mapIconScale,
		30 * _mapIconScale,
		0,
		_smartMines,
		1,
		0.038 * _mapIconScale,
		"PuristaBold",
		"right"
	];

	if (_detonationDistance <= 0) then { continue; };
	_drawSemiCircles pushBack [
		_angle,
		[1, 1, 1, 0.3],
		_position,
		_detonationDistance,
		getDirVisual _x,
		false
	];
} forEach _advancedMines;

// Draw minefields
private _minefields = _mapData getOrDefault ["minefields", []];
{
	private _position = getPosASL _x;

	_drawRectangles pushBack [
		_position,
		50,
		10,
		getDir _x,
		[1, 1, 1, 1],
		"#(rgb,1,1,1)color(1,0,0,0.2)"
	];
} forEach _minefields;

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

{
	private _position = getPosASL _x;
	_drawIcons pushBack [
		"\A3\ui_f\data\IGUI\RscCustomInfo\Sensors\Targets\missile_ca.paa",
		[1, 0, 0, 1],
		_position,
		20 * _mapIconScale,
		20 * _mapIconScale,
		0,
		_x getVariable ["WL2_missileType", ""],
		0,
		0.04 * _mapIconScale,
		"PuristaBold",
		"right"
	];
} forEach (_mapData getOrDefault ["trackedProjectiles", []]);

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
	private _storedDrawSemiCircles = missionNamespace getVariable ["WL2_drawSemiCircles", []];
	private _storedDrawRectangles = missionNamespace getVariable ["WL2_drawRectangles", []];
	private _storedDrawPolygons = missionNamespace getVariable ["WL2_drawPolygons", []];
	private _storedSectorIcons = missionNamespace getVariable ["WL2_drawSectorIcons", []];

	_storedDrawIcons pushBack _drawIcons;
	_storedDrawEllipses pushBack _drawEllipses;
	_storedDrawRectangles pushBack _drawRectangles;
	_storedDrawPolygons pushBack _drawPolygons;
	_storedSectorIcons pushBack _drawSectorIcons;
} else {
	uiNamespace setVariable ["WL2_drawIcons", _drawIcons];
	uiNamespace setVariable ["WL2_drawIconsAnimated", _drawIconsAnimated];
	uiNamespace setVariable ["WL2_drawIconsSelectable", _drawIconsSelectable];
	uiNamespace setVariable ["WL2_drawIconsFollowMouse", _drawIconsFollowMouse];
	uiNamespace setVariable ["WL2_drawEllipses", _drawEllipses];
	uiNamespace setVariable ["WL2_drawSemiCircles", _drawSemiCircles];
	uiNamespace setVariable ["WL2_drawRectangles", _drawRectangles];
	uiNamespace setVariable ["WL2_drawPolygons", _drawPolygons];
	uiNamespace setVariable ["WL2_drawLines", _drawLines];
};

uiNamespace setVariable ["WL2_mapColorCache", _mapColorCache];
uiNamespace setVariable ["WL2_mapIconCache", _mapIconCache];
uiNamespace setVariable ["WL2_mapTextCache", _mapTextCache];
uiNamespace setVariable ["WL2_mapSizeCache", _mapSizeCache];