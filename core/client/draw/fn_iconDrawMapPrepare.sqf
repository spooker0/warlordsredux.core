#include "includes.inc"
// _drawMode: 0 = normal, 1 = spectator, 2 = stored
params [["_map", controlNull], ["_drawMode", 0]];

if (isNull _map) exitWith {};

private _drawAll = _drawMode == 1 || _drawMode == 2;
private _draw = (ctrlMapScale _map) < 0.3 || _drawMode == 2;
private _playerUid = getPlayerUID player;

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
private _teamColor = _mapData getOrDefault ["teamColor", [0.4, 0, 0.5, 0.8]];

private _settingsMap = missionProfileNamespace getVariable ["WL2_settings", createHashMap];
private _mapIconScale = _settingsMap getOrDefault ["mapIconScale", 1];

// Draw sector links
private _sectorTarget = WL_SectorActionTarget;
private _mapSectorModifierSize = _settingsMap getOrDefault ["mapSectorModifierSize", 1];

private _mapMode = uiNamespace getVariable ["WL2_mapMode", 0];
private _showDetailedMode = inputAction "lookAround" > 0 || _map getVariable ["WL2_showDetailedMode", false];
private _showAirMode = _mapMode == 1;
private _showSectorLinks = _drawMode != 0 || WL_VotePhase != 0 || _showDetailedMode;

private _sectorsInLinksShown = [];
if (_showSectorLinks) then {
	private _allRegionLines = uiNamespace getVariable ["WL2_drawRegionLines", []];
	_drawLines append _allRegionLines;
} else {
	if (!isNull _sectorTarget) then {
		private _sectorLines = _sectorTarget getVariable ["WL2_drawSectorLines", []];
		_drawLines append _sectorLines;
	};
};

// Draw sector capture modifiers
private _areaControlData = _mapData getOrDefault ["areaControlData", ["", ""]];
private _friendFlag = if (_side == west) then {
	"\A3\ui_f\data\map\markers\flags\nato_ca.paa"
} else {
	"\A3\ui_f\data\map\markers\flags\csat_ca.paa"
};
private _enemyFlag = if (_side == west) then {
	"\A3\ui_f\data\map\markers\flags\csat_ca.paa"
} else {
	"\A3\ui_f\data\map\markers\flags\nato_ca.paa"
};
_drawIcons pushBack [
	_friendFlag,
	[1, 1, 1, 0.8],
	[15000, 15000, 0],
	30,
	30,
	0,
	_areaControlData # 0
];
_drawIcons pushBack [
	_enemyFlag,
	[1, 1, 1, 0.8],
	[15000, 14800, 0],
	30,
	30,
	0,
	_areaControlData # 1
];

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

if (uiNamespace getVariable ["WL2_isOrderingWater", false]) then {
	// All sectors within 1.5km
	private _mousePosition = getMousePosition;
	private _mouseWorldPosition = _map ctrlMapScreenToWorld _mousePosition;

	private _waterDropCost = uiNamespace getVariable ["WL2_waterDropCost", -1];
	if (_waterDropCost >= 1000) then {
		private _forwardBases = missionNamespace getVariable ["WL2_forwardBases", []];
		private _spawnLocations = _forwardBases select {
			_x getVariable ["WL2_forwardBaseOwner", sideUnknown] == _side
		};
		private _teamSectorsData = WL_SECTORS_DATA(_side);
		private _linkedSectors = _teamSectorsData getOrDefault ["linked", []];
		_spawnLocations append _linkedSectors;

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
		300,
		300,
		0,
		[1, 1, 1, 1],
		""
	];
};

private _assetTargets = WL_AssetActionTargets;

// Draw sector selector
if (!isNull _sectorTarget) then {
	private _sectorPos = getPosASL _sectorTarget;
	if (isNull BIS_WL_highlightedSector && WL_SectorActionTargetActive) then {
		_drawIcons pushBack [
			"A3\ui_f\data\map\groupicons\selector_selectedMission_ca.paa",
			_teamColor,
			_sectorPos,
			50,
			50,
			0
		];
	};

	private _sectorArea = _sectorTarget getVariable ["objectAreaComplete", []];

	if (count _sectorArea >= 5) then {
		private _isRectangle = _sectorArea # 4;
		if (_isRectangle) then {
			_drawRectangles pushBack [
				_sectorArea # 0,
				_sectorArea # 1,
				_sectorArea # 2,
				_sectorArea # 3,
				[1, 1, 1, 1],
				"#(rgb,1,1,1)color(1,1,1,0.3)"
			];
		} else {
			_drawEllipses pushBack [
				_sectorArea # 0,
				_sectorArea # 1,
				_sectorArea # 2,
				_sectorArea # 3,
				[1, 1, 1, 1],
				"#(rgb,1,1,1)color(1,1,1,0.3)"
			];
		};
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

	{
		private _sectorOwner = _x getVariable ["BIS_WL_owner", independent];
		if (_sectorOwner == independent) then {
			continue;
		};

		private _sectorRevealed = _x getVariable ["BIS_WL_revealedBy", []];
		if !(_side in _sectorRevealed) then {
			continue;
		};

		private _sectorAddColor = if (_sectorOwner == west) then {
			[0, 0.3, 0.6, 1]
		} else {
			[0.5, 0, 0, 1]
		};
		private _directionVector = _sectorTarget getRelDir (getPosASL _x);
		private _addDrawPos = _sectorTarget getRelPos [200, _directionVector];

		private _modifierText = if (_x in WL_BASES) then { "+2x" } else { "+1x" };
		_drawIcons pushBack [
			"#(rgb,1,1,1)color(1,1,1,1)",
			_sectorAddColor,
			_addDrawPos,
			0,
			0,
			0,
			_modifierText,
			2,
			0.075 * _mapSectorModifierSize,
			"PuristaSemibold",
			"center"
		];
	} forEach (_sectorTarget getVariable ["WL2_connectedSectors", []]);
};

// Draw team priority
private _teamPriorityVar = format ["WL2_teamPriority_%1", _side];
private _teamPriority = missionNamespace getVariable [_teamPriorityVar, objNull];
if (alive _teamPriority) then {
	private _teamPriorityTypeVar = format ["WL2_teamPriorityType_%1", _side];
	private _teamPriorityType = missionNamespace getVariable [_teamPriorityTypeVar, ""];

	_drawIcons pushBack [
		"\A3\ui_f\data\map\markers\military\circle_CA.paa",
		[1, 1, 1, 1],
		getPosASL _teamPriority,
		40 * _mapIconScale,
		40 * _mapIconScale,
		0
	];
};

// Draw sector areas
if (_showSectorLinks) then {
	private _regionMap = uiNamespace getVariable ["WL2_drawRegionMap", createHashMap];
	{
		_y params ["_regionText", "_regionShape"];

		_drawIcons pushBack _regionText;
		_drawPolygons pushBack _regionShape;
	} forEach _regionMap;
} else {
	if (!isNull _sectorTarget) then {
		private _regionMap = uiNamespace getVariable ["WL2_drawRegionMap", createHashMap];
		private _regionIds = _sectorTarget getVariable ["WL2_drawRegionIds", []];
		{
			private _regionData = _regionMap getOrDefault [_x, [[], []]];
			_regionData params ["_regionText", "_regionShape"];

			_drawIcons pushBack _regionText;
			_drawPolygons pushBack _regionShape;
		} forEach _regionIds;
	};
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

	if (_baseOwner == _side) then {
		_drawIconsSelectable pushBack _base;
	};

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

		if (_sectorTarget != _x) then {
			continue;
		};

		private _addDrawPos = vectorLinearConversion [0, 1, 0.2, _endPoint, _sectorPos];
		_drawIcons pushBack [
			"#(rgb,1,1,1)color(1,1,1,1)",
			_baseColor,
			_addDrawPos,
			0,
			0,
			0,
			format ["+%1x", WL_FOB_CAPMODIFIER],
			2,
			0.075 * _mapSectorModifierSize,
			"PuristaSemibold",
			"center"
		];
	} forEach _sectorsInRange;
} forEach _forwardBases;

// Draw strongholds
if (_draw) then {
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
			format ["  STRONGHOLD (%1/%2)", _strongholdHealth, _maxHealth],
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

		private _strongholdSector = _stronghold getVariable ["WL_strongholdSector", objNull];
		private _sectorOwner = _strongholdSector getVariable ["BIS_WL_owner", sideUnknown];
		if (_sectorOwner == _side) then {
			_drawIconsSelectable pushBack _stronghold;
		};
	} forEach (_mapData getOrDefault ["strongholds", []]);
};

// Draw scanned units
private _scannedUnits = _mapData getOrDefault ["scannedUnits", []];
{
	if (_showAirMode) then {
		if !(_x isKindOf "Air" || WL_UNIT(_x, "category", "Other") == "Air Defense") then {
			continue;
		};
	};
	private _hideMap = _x getVariable ["WL2_hideMap", 0];
	private _scanText = if (_hideMap == 0 && _draw) then {
		if (_showDetailedMode) then {
			_x getVariable ["WL2_mapIconTextDetailed", ""]
		} else {
			_x getVariable ["WL2_mapIconText", ""]
		};
	} else {
		""
	};
	private _position = getPosASL _x;
	private _size = _x getVariable ["WL2_mapIconSize", 19];
	private _textSize = if (_x isKindOf "Man") then { 0.025 } else { 0.043 };
	_drawIcons pushBack [
		_x getVariable ["WL2_mapIconType", ""],
		_x getVariable ["WL2_mapIconColor", [1, 1, 1, 1]],
		_position,
		_size * _mapIconScale,
		_size * _mapIconScale,
		getDirVisual _x,
		_scanText,
		1,
		_textSize * _mapIconScale,
		"PuristaBold",
		"right"
	];
} forEach _scannedUnits;

// Draw scanner
private _assetData = WL_ASSET_DATA;

private _scanners = _mapData getOrDefault ["scanners", []];
{
	if (isNull _x) then { continue; };

	private _position = getPosASL _x;

    private _scanRadius = _x getVariable ["WL_scanRadius", -1];
	if (_scanRadius < 0) then { continue; };

	_drawEllipses pushBack [
		_position,
		_scanRadius,
		_scanRadius,
		0,
		[0, 1, 1, 1],
		"#(rgb,1,1,1)color(0,1,1,0.15)"
	];
} forEach _scanners;

// Combat air patrol areas
private _combatAirAreas = _mapData getOrDefault ["combatAirAreas", []];
private _assetTargetsInCombatAir = _assetTargets arrayIntersect _combatAirAreas;
if (cameraOn isKindOf "Air" || _showAirMode || _sectorTarget in _combatAirAreas || count _assetTargetsInCombatAir > 0) then {
	{
		private _targetPos = getPosASL _x;
		private _targetOwner = if (typeof _x == "RuggedTerminal_01_communications_hub_F") then {
			_x getVariable ["WL2_forwardBaseOwner", independent];
		} else {
			_x getVariable ["BIS_WL_owner", independent];
		};

		private _mapColor = switch (_targetOwner) do {
			case west: { [0, 0.3, 0.6, 0.1] };
			case east: { [0.5, 0, 0, 0.1] };
			case independent: { [0, 0.6, 0, 0.1] };
			default { [1, 1, 1, 0.1] };
		};
		private _mapTexture = switch (_targetOwner) do {
			case west: { "#(rgb,1,1,1)color(0,0,1,1)" };
			case east: { "#(rgb,1,1,1)color(1,0,0,1)" };
			case independent: { "#(rgb,1,1,1)color(0,1,0,1)" };
			default { "#(rgb,1,1,1)color(1,0,1,1)" };
		};

		private _startTime = _x getVariable ["WL2_combatAirStart", 0];
		private _timeElapsed = serverTime - _startTime;
		private _timeStepsElapsed = 5 * ceil (_timeElapsed / 5);
		private _areaRadius = _timeStepsElapsed * WL_COMBAT_AIR_PERSEC;

		private _combatAreaMax = if (_x in [WL2_base1, WL2_base2]) then {
			WL_COMBAT_AIR_RADIUS_BASE
		} else {
			WL_COMBAT_AIR_RADIUS
		};
		_areaRadius = _areaRadius min _combatAreaMax;
		_drawEllipses pushBack [
			_targetPos,
			_areaRadius,
			_areaRadius,
			0,
			_mapColor,
			_mapTexture
		];
	} forEach _combatAirAreas;
};

// Draw squad lines
private _allSquadmates = _mapData getOrDefault ["allSquadmates", []];
if (count (_assetTargets arrayIntersect _allSquadmates) > 0 || _showDetailedMode) then {
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
private _mapIconTextSize = _iconTextSize * _mapIconScale;

// Draw vehicles
private _sideVehicles = _mapData getOrDefault ["sideVehicles", []];
{
	if (_showAirMode) then {
		if !(_x isKindOf "Air" || WL_UNIT(_x, "category", "Other") == "Air Defense") then {
			continue;
		};
	};
	private _position = getPosASL _x;
	private _size = _x getVariable ["WL2_mapIconSize", 19];
	private _hideMap = _x getVariable ["WL2_hideMap", 0];
	if (_hideMap == 2 && !_showDetailedMode) then {
		continue;
	};
	private _iconText = if (_hideMap == 0 && _draw) then {
		if (_showDetailedMode) then {
			_x getVariable ["WL2_mapIconTextDetailed", ""]
		} else {
			_x getVariable ["WL2_mapIconText", ""]
		};
	} else {
		""
	};
	private _direction = if (WL_ISUP(_x)) then { getDirVisual _x } else { 0 };
	_drawIcons pushBack [
		_x getVariable ["WL2_mapIconType", ""],
		_x getVariable ["WL2_mapIconColor", [1, 1, 1, 1]],
		_position,
		_size * _mapIconScale,
		_size * _mapIconScale,
		getDirVisual _x,
		_iconText,
		1,
		_mapIconTextSize,
		"PuristaBold",
		"right"
	];
	if (_x == player) then {
		continue;
	};
	if (_hideMap == 1 && !_showDetailedMode) then {
		private _ownerUid = _x getVariable ["BIS_WL_ownerAsset", "123"];
		if (_ownerUid != _playerUid) then {
			private _access = _x getVariable ["WL2_accessControl", -1];
			if (_access != 0) then {
				continue;
			};
		};
	};
	_drawIconsSelectable pushBack _x;
} forEach _sideVehicles;

private _checkForAirRadar = if (_showAirMode) then {
	_sideVehicles
} else {
	_assetTargets + [cameraOn];
};
{
	private _airRadar = _x getVariable ["WL2_airRadar", -1];
	if (_airRadar > 0) then {
		_drawSemiCircles pushBack [
			60,
			[1, 1, 1, 0.5],
			getPosASL _x,
			_airRadar,
			getDirVisual _x,
			true
		];
	};
} forEach _checkForAirRadar;

// Draw asset selector
private _drawCirclesFor = if (_showAirMode) then {
	_sideVehicles;
} else {
	_assetTargets
};
{
	if (_showAirMode) then {
		if (_x isKindOf "Land_Cargo10_military_green_F") then {
			continue;
		};
		if (_x isKindOf "RuggedTerminal_01_communications_hub_F") then {
			continue;
		};
	};
	if (_x in _assetTargets) then {
		_drawIconsAnimated pushBack [
			"A3\ui_f\data\map\groupicons\selector_selectedMission_ca.paa",
			_teamColor,
			getPosASL _x,
			40,
			40,
			0
		];
	};

	private _mapCircleRadius = _x getVariable ["WL2_mapCircleRadius", 0];
	if (_mapCircleRadius > 0) then {
		_drawEllipses pushBack [
			getPosASL _x,
			_mapCircleRadius,
			_mapCircleRadius,
			0,
			_teamColor,
			""
		];
	};
} forEach _drawCirclesFor;

// Draw visible enemy units
if (!_showAirMode) then {
	private _visibleEnemyUnits = _mapData getOrDefault ["visibleEnemyUnits", []];
	{
		private _position = getPosASL _x;
		private _size = _x getVariable ["WL2_mapIconSize", 19];
		private _iconText = if (_draw) then {
			if (_showDetailedMode) then {
				_x getVariable ["WL2_mapIconTextDetailed", ""]
			} else {
				_x getVariable ["WL2_mapIconText", ""]
			};
		} else {
			""
		};
		_drawIcons pushBack [
			_x getVariable ["WL2_mapIconType", ""],
			_x getVariable ["WL2_mapIconColor", [1, 1, 1, 1]],
			_position,
			_size * _mapIconScale,
			_size * _mapIconScale,
			getDirVisual _x,
			_iconText,
			1,
			_mapIconTextSize,
			"PuristaBold",
			"right"
		];
	} forEach _visibleEnemyUnits;
};

// Draw plane wrecks
private _airWrecks = _mapData getOrDefault ["airWrecks", []];
{
	private _position = getPosASL _x;
	private _wreckValue = _x getVariable ["WL2_wreckValue", 0];

	private _deadTime = _x getVariable ["WL2_timeOfDeath", -1];
	private _wreckTime = if (_deadTime >= 0) then {
		serverTime - _deadTime
	} else {
		_x getEntityInfo 3
	};

	private _wreckTimer = [_wreckTime, "MM:SS"] call BIS_fnc_secondsToString;
	_drawIcons pushBack [
		"\a3\Ui_F_Curator\Data\CfgMarkers\kia_ca.paa",
		[0, 0, 0, 1],
		_position,
		23 * _mapIconScale,
		23 * _mapIconScale,
		0,
		format ["WRECK (%1%2, %3)", WL_MONEY_SIGN, _wreckValue, _wreckTimer],
		1,
		_mapIconTextSize,
		"PuristaBold",
		"right"
	];
} forEach _airWrecks;

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
	private _ownsMine = (_x getVariable ["BIS_WL_ownerAsset", "123"]) == _playerUid;
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
if (!_showAirMode) then {
	private _minefields = _mapData getOrDefault ["minefields", []];
	{
		if (!alive _x) then {
			continue;
		};

		private _position = getPosASL _x;
		private _mineData = _x getVariable ["WL2_minefield", []];

		if (count _mineData < 3) then {
			continue;
		};

		private _isRectangle = _mineData # 2 == 1;
		if (_isRectangle) then {
			_drawRectangles pushBack [
				_position,
				_mineData # 0,
				_mineData # 1,
				getDir _x,
				[1, 1, 1, 1],
				"#(rgb,1,1,1)color(1,0,0,0.15)"
			];
		} else {
			_drawEllipses pushBack [
				_position,
				_mineData # 0,
				_mineData # 1,
				getDir _x,
				[1, 1, 1, 1],
				"#(rgb,1,1,1)color(1,0,0,0.15)"
			];
		};
	} forEach _minefields;
};

private _drawSectorMarkerThreshold = _mapData getOrDefault ["sectorMarkerThreshold", 0.4];
private _drawSectorMarkerText = (ctrlMapScale _map) < _drawSectorMarkerThreshold;

private _sectorMarkers = _mapData getOrDefault ["teamSectorMarkers", []];
{
	private _marker = [_x, _side] call WL2_fnc_drawSectorMarker;
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