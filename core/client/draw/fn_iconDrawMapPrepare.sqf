#include "..\..\warlords_constants.inc"

params [["_map", controlNull]];

private _drawIcons = [];
private _drawIconsAnimated = [];
private _drawIconsSelectable = [];
private _drawEllipses = [];
private _drawLines = [];

private _side = BIS_WL_playerSide;

// Draw white hover selector
if !(isNull BIS_WL_highlightedSector) then {
	_drawIconsAnimated pushBack [
		"A3\ui_f\data\map\groupicons\selector_selectedMission_ca.paa",
		[1,1,1,0.5],
		BIS_WL_highlightedSector,
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
		BIS_WL_targetVote,
		60,
		60,
		0
	];
};

// Draw asset selector
if (!isNull WL_AssetActionTarget) then {
	_drawIconsAnimated pushBack [
		"A3\ui_f\data\map\groupicons\selector_selectedMission_ca.paa",
		[] call WL2_fnc_iconColor,
		WL_AssetActionTarget,
		40,
		40,
		0
	];
};

// Draw sector selector
if (!isNull WL_SectorActionTarget && isNull BIS_WL_highlightedSector && WL_SectorActionTargetActive) then {
	_drawIconsAnimated pushBack [
		"A3\ui_f\data\map\groupicons\selector_selectedMission_ca.paa",
		[] call WL2_fnc_iconColor,
		WL_SectorActionTarget,
		50,
		50,
		0
	];
};

// Draw player tent
private _respawnBag = player getVariable ["WL2_respawnBag", objNull];
if (alive _respawnBag) then {
	private _bagPos = getPosATL _respawnBag;
	_drawIcons pushBack [
		"\A3\ui_f\data\map\markers\military\triangle_CA.paa",
		[player] call WL2_fnc_iconColor,
		getPosATL _respawnBag,
		50,
		50,
		0,
		"Tent"
	];
	_drawIconsSelectable pushBack [_respawnBag, _bagPos];
};

// Draw forward bases
private _forwardBases = missionNamespace getVariable ["WL2_forwardBases", []];
{
	private _base = _x;
	private _baseOwner = _base getVariable ["WL2_forwardBaseOwner", sideUnknown];
	private _baseColor = switch (_baseOwner) do {
		case west: { [0, 0.3, 0.6, 0.9] };
		case east: { [0.5, 0, 0, 0.9] };
		case independent: { [0, 0.6, 0, 0.9] };
		default { [1, 1, 1, 0] };
	};

	private _baseTime = _base getVariable ["WL2_forwardBaseTime", -1];
	private _baseLevel = _base getVariable ["WL2_forwardBaseLevel", 0];

	private _waitText = if (serverTime < _baseTime) then {
		private _timeRemaining = _baseTime - serverTime;
		private _timeString = [_timeRemaining, "MM:SS"] call BIS_fnc_secondsToString;
		private _infoString = if (_baseLevel == 0) then {
			"Constructing"
		} else {
			"Upgrading"
		};
		format ["(%1 %2)", _infoString, _timeString];
	} else {
		""
	};

	private _basePos = getPosATL _base;
	private _baseRadius = switch (_baseLevel) do {
		case 0: { 100 };
		case 1: { 150 };
		case 2: { 250 };
		case 3: { 500 };
		default { 100 };
	};
	if (_baseOwner != _side && (player distance2D _basePos > _baseRadius) && !WL_IsSpectator) then {
		continue;
	};

	private _baseType = switch (_baseLevel) do {
		case 0: {
			"Forward Construction Site"
		};
		case 1: {
			"Forward Outpost"
		};
		case 2: {
			"Forward Base"
		};
		case 3: {
			"Forward HQ"
		};
		default {
			"Forward Outpost"
		};
	};

	_drawIcons pushBack [
		"\A3\ui_f\data\map\mapcontrol\Tourism_CA.paa",
		_baseColor,
		_basePos,
		30,
		30,
		0,
		format ["%1 %2", _baseType, _waitText]
	];
	_drawIconsSelectable pushBack [_base, _basePos];

	_drawEllipses pushBack [
		_basePos,
		_baseRadius,
		_baseRadius,
		0,
		_baseColor,
		""
	];
} forEach _forwardBases;

// Draw sector scans
private _sectorScannedUnits = [];
{
	private _detectedUnits = _x getVariable ["WL2_detectedUnits", []];
	_sectorScannedUnits append _detectedUnits;
} forEach BIS_WL_currentlyScannedSectors;

private _strongholdScannedUnits = missionNamespace getVariable ["WL2_strongholdDetectedUnits", []];
{
	private _size = call WL2_fnc_iconSize;
	_drawIcons pushBack [
		call WL2_fnc_iconType,
		switch ([_x] call WL2_fnc_getAssetSide) do {
			case west: { [0, 0.3, 0.6, 0.9] };
			case east: { [0.5, 0, 0, 0.9] };
			case independent: { [0, 0.6, 0, 0.9] };
			default { [1, 1, 1, 1] };
		},
		call WL2_fnc_getPos,
		_size,
		_size,
		call WL2_fnc_getDir,
		_x call WL2_fnc_iconTextSectorScan,
		1,
		0.043,
		"PuristaBold",
		"right"
	];
} forEach (_sectorScannedUnits + _strongholdScannedUnits);

// Draw EW networks
private _activeVehicles = vehicles select {
	alive _x &&
	isEngineOn _x
};

private _ewNetworkUnits = _activeVehicles + ("Land_MobileRadar_01_radar_F" allObjects 0) select {
	(_x getVariable ["WL_ewNetActive", false] ||
	_x getVariable ["WL_ewNetActivating", false]) &&
	alive _x
};

{
	if (isNull _x) then { continue; };
	private _assetPos = _x modelToWorldVisual [0, 0, 0];
	private _assetSide = [_x] call WL2_fnc_getAssetSide;
	private _assetColor = switch (_assetSide) do {
		case west: { [0, 0.3, 0.6, 0.9] };
		case east: { [0.5, 0, 0, 0.9] };
		case independent: { [0, 0.6, 0, 0.9] };
		default { [1, 1, 1, 0] };
	};
	private _range = _x getVariable ["WL_ewNetRange", 0];
	_drawEllipses pushBack [
		_assetPos,
		_range,
		_range,
		0,
		_assetColor,
		""
	];
} forEach _ewNetworkUnits;

// Draw scanner and scanned units
private _scannerUnits = _activeVehicles select {
	_x getVariable ["WL_scannerOn", false] &&
	(([_x] call WL2_fnc_getAssetSide) == _side || WL_IsSpectator)
};

private _mySideColor = switch (_side) do {
	case west: { [0, 0.3, 0.6, 0.9] };
	case east: { [0.5, 0, 0, 0.9] };
	case independent: { [0, 0.6, 0, 0.9] };
	default { [1, 1, 1, 0] };
};

private _hasAWACSMap = missionNamespace getVariable ["WL2_hasAWACS", createHashMap];
private _scale = 6.4 * worldSize / 8192 * ctrlMapScale _map;
{
	if (isNull _x) then { continue; };
	private _assetPos = _x modelToWorldVisual [0, 0, 0];
    private _scanRadius = _x getVariable ["WL_scanRadius", 100];
	if (_scanRadius == 0) then { continue; };
    private _assetActualType = _x getVariable ["WL2_orderedClass", typeOf _x];
	if (_hasAWACSMap getOrDefault [_assetActualType, false]) then {
		private _size = _scanRadius / _scale;
		_drawIcons pushBack [
			"\a3\ui_f\data\IGUI\RscCustomInfo\Sensors\Sectors\sector120_ca.paa",
			[1, 1, 1, 0.3],
			_assetPos,
			_size,
			_size,
			getDirVisual _x
		];
		_drawEllipses pushBack [
			_assetPos,
			_scanRadius,
			_scanRadius,
			0,
			_mySideColor,
			""
		];
	} else {
		_drawEllipses pushBack [
			_assetPos,
			_scanRadius,
			_scanRadius,
			0,
			[0, 1, 1, 1],
			"#(rgb,1,1,1)color(0,1,1,0.15)"
		];
	};
} forEach _scannerUnits;

private _allScannedObjects = [];
{
	private _scannedObjects = _x getVariable ["WL_scannedObjects", []];
	_allScannedObjects append _scannedObjects;
} forEach _scannerUnits;
_allScannedObjects = _allScannedObjects arrayIntersect _allScannedObjects; // eliminate duplicates

{
	if (isNull _x) then { continue; };
	private _size = call WL2_fnc_iconSize * 1.2;
	private _objToColor = if ([_x] call WL2_fnc_isScannerMunition) then {
		getShotParents _x # 0;
	} else {
		_x
	};
	_drawIcons pushBack [
		call WL2_fnc_iconType,
		switch ([_objToColor] call WL2_fnc_getAssetSide) do {
			case west: { [0, 0.3, 0.6, 0.9] };
			case east: { [0.5, 0, 0, 0.9] };
			case independent: { [0, 0.6, 0, 0.9] };
			default { [1, 1, 1, 1] };
		},
		call WL2_fnc_getPos,
		_size,
		_size,
		call WL2_fnc_getDir,
		_x call WL2_fnc_iconTextSectorScan,
		1,
		0.06,
		"PuristaBold",
		"right"
	];
} forEach _allScannedObjects;

private _draw = (ctrlMapScale _map) < 0.3;
// Dead players
{
	_drawIcons pushBack [
		"\a3\Ui_F_Curator\Data\CfgMarkers\kia_ca.paa",
		[1, 0, 0, 0.8],
		call WL2_fnc_getPos,
		20,
		20,
		0,
		if (_draw) then {format ["%1 [K.I.A.]", (name _x)]} else {""},
		1,
		0.043,
		"PuristaBold",
		"right"
	];
} forEach (allPlayers select {
	(!alive _x) && (side group _x == _side || WL_IsSpectator)
});

// Teammates
{
	_size = call WL2_fnc_iconSize;
	if (_x == player) then {
		_drawIcons pushBack [
			'a3\ui_f\data\igui\cfg\islandmap\iconplayer_ca.paa',
			[1,0,0,1],
			call WL2_fnc_getPos,
			_size,
			_size,
			0,
			"",
			1,
			0.043,
			"PuristaBold",
			"right"
		];
	};

	private _teammatePos = call WL2_fnc_getPos;
	_drawIcons pushBack [
		call WL2_fnc_iconType,
		[_x] call WL2_fnc_iconColor,
		_teammatePos,
		_size,
		_size,
		call WL2_fnc_getDir,
		if (_draw) then {
			private _levelDisplay = _x getVariable ["WL_playerLevel", "Recruit"];
			private _displayName = format ["%1 [%2]", name _x, _levelDisplay];
			_displayName
		} else {""},
		1,
		0.043,
		"PuristaBold",
		"right"
	];
	_drawIconsSelectable pushBack [_x, _teammatePos];
} forEach (allPlayers select {(side group _x == _side) && {(isNull objectParent _x) && {(alive _x)}}});

// AI in vehicle
{
	_size = call WL2_fnc_iconSize;
	_drawIcons pushBack [
		call WL2_fnc_iconType,
		[_x] call WL2_fnc_iconColor,
		call WL2_fnc_getPos,
		_size,
		_size,
		call WL2_fnc_getDir,
		if (_draw) then {format ["%1 [AI]", (name _x)]} else {""},
		1,
		0.043,
		"PuristaBold",
		"right"
	];
} forEach ((allUnits) select {(side group (crew _x select 0) == _side || WL_IsSpectator) && {(alive _x) && {(isNull objectParent _x) && {typeOf _x != "Logic" && {!(isPlayer _x)}}}}});

// AI
{
	_size = call WL2_fnc_iconSize;
	private _aiPos = call WL2_fnc_getPos;
	_drawIcons pushBack [
		call WL2_fnc_iconType,
		[_x] call WL2_fnc_iconColor,
		_aiPos,
		_size,
		_size,
		call WL2_fnc_getDir,
		if (_draw) then {if (isPlayer _x) then {name _x} else {format ["%1 [AI]", (name _x)]}} else {""},
		1,
		0.043,
		"PuristaBold",
		"right"
	];
	_drawIconsSelectable pushBack [_x, _aiPos];
} forEach ((units player) select {(alive _x) && {(isNull objectParent _x) && {_x != player}}});

// Draw squad lines
private _allSquadmates = ["getAllInSquad"] call SQD_fnc_client;
_allSquadmates = _allSquadmates apply {
	vehicle _x;
};
if (WL_AssetActionTarget in _allSquadmates) then {
	private _squadLeader = _allSquadmates select {
		["isSquadLeader", [getPlayerID _x]] call SQD_fnc_client;
	};

	if (count _squadLeader > 0) then {
		_squadLeader = _squadLeader # 0;
		_allSquadmates = _allSquadmates - [_squadLeader];
		{
			_drawLines pushBack [
				_squadLeader,
				_x,
				[0, 1, 1, 0.8],
				6
			];
		} forEach _allSquadmates;
	};
};

// Draw vehicles
private _teamVariable = switch (_side) do {
	case west: { "BIS_WL_westOwnedVehicles" };
	case east: { "BIS_WL_eastOwnedVehicles" };
	case independent: { "BIS_WL_guerOwnedVehicles" };
	default { "" };
};
private _sideVehicles = if (_teamVariable != "") then {
	missionNamespace getVariable [_teamVariable, []];
} else {
	[]
};
private _vehiclesOnSide = vehicles select { count crew _x > 0 && side _x == _side };
_sideVehicles = _sideVehicles + _vehiclesOnSide;
_sideVehicles = _sideVehicles arrayIntersect _sideVehicles;

if (WL_IsSpectator) then {
	_sideVehicles = vehicles select {
		_x getVariable ["WL_spawnedAsset", false]
	};
};

{
	_size = call WL2_fnc_iconSize;
	private _vehiclePos = call WL2_fnc_getPos;
	_drawIcons pushBack [
		call WL2_fnc_iconType,
		[_x] call WL2_fnc_iconColor,
		_vehiclePos,
		_size,
		_size,
		call WL2_fnc_getDir,
		_x call WL2_fnc_iconText,
		1,
		0.043,
		"PuristaBold",
		"right"
	];
	_drawIconsSelectable pushBack [_x, _vehiclePos];
} forEach (_sideVehicles select { alive _x });

// Spectator draw
if (WL_IsSpectator) then {
	private _camera = missionNamespace getVariable ["BIS_EGSpectatorCamera_camera", objNull];

	if !(isNull _camera) then {
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

uiNamespace setVariable ["WL2_drawIcons", _drawIcons];
uiNamespace setVariable ["WL2_drawIconsAnimated", _drawIconsAnimated];
uiNamespace setVariable ["WL2_drawIconsSelectable", _drawIconsSelectable];
uiNamespace setVariable ["WL2_drawEllipses", _drawEllipses];
uiNamespace setVariable ["WL2_drawLines", _drawLines];