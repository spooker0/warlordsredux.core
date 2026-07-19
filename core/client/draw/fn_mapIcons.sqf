#include "includes.inc"
// Slow loop
0 spawn {
	while { !BIS_WL_missionEnd } do {
		private _minimapDisplay = uiNamespace getVariable ["RscWLMinimap", displayNull];
		private _minimapControl = _minimapDisplay displayCtrl 1200;

		private _mainMap = (findDisplay 12) displayCtrl 51;
		private _maps = [
			_mainMap,
			(findDisplay 160) displayCtrl 51,
			(findDisplay -1) displayCtrl 500,
			_minimapControl
		];
		{
			private _gps = _x displayCtrl 101;
			if (!isNull _gps) then {
				_maps pushBack _gps;
			};
		} forEach (uiNamespace getVariable ["IGUI_displays", displayNull]);

		{
			private _map = _x;
			if (isNull _map) then {
				continue;
			};
			private _mapDrawn = _map getVariable ["WL2_mapDrawn", false];
			if (!_mapDrawn) then {
				_map ctrlRemoveAllEventHandlers "Draw";
				_map ctrlAddEventHandler ["Draw", WL2_fnc_iconDrawMap];
				_map setVariable ["WL2_mapDrawn", true];

				if (_x == _mainMap) then {
					_map ctrlAddEventHandler ["Draw", WL2_fnc_mapEachFrame];
				};
			};
		} forEach _maps;

		uiNamespace setVariable ["WL2_allMaps", _maps];

		uiSleep 1;
	};
};

// Refresh unit loop
0 spawn {
	private _mapData = createHashMap;
	private _assetData = WL_ASSET_DATA;
	missionNamespace setVariable ["WL2_mapData", _mapData];
	private _playerId = getPlayerID player;
	private _settingsMap = missionProfileNamespace getVariable ["WL2_settings", createHashMap];

	while { !BIS_WL_missionEnd } do {
		private _isAfk = player getVariable ["WL2_afk", false];
		if (_isAfk) then {
			_mapData = createHashMap;
			missionNamespace setVariable ["WL2_mapData", _mapData];
			uiSleep 5;
			continue;
		};

		private _isSpectator = WL_IsSpectator;

		private _side = BIS_WL_playerSide;
		_mapData set ["side", _side];

		private _waypoints = waypoints group cameraOn;
		_mapData set ["uavWaypoints", _waypoints];

		private _strongholds = missionNamespace getVariable ["WL_strongholds", []];
		private _visibleStrongholds = _strongholds select {
			private _sector = _x getVariable ["WL_strongholdSector", objNull];
			private _sectorOwner = _sector getVariable ["BIS_WL_owner", independent];
			BIS_WL_playerSide == _sectorOwner || _sector == WL_TARGET_FRIENDLY || WL_IsSpectator
		};
		_mapData set ["strongholds", _visibleStrongholds];

		private _allSquadmates = ["getSquadmates", [_playerId, true]] call SQD_fnc_query;
		_allSquadmates = _allSquadmates apply { vehicle _x };
		_mapData set ["allSquadmates", _allSquadmates];

		private _sideVehicles = if (_isSpectator) then {
			BIS_WL_westOwnedVehicles + BIS_WL_eastOwnedVehicles + BIS_WL_guerOwnedVehicles;
		} else {
			switch (_side) do {
				case west: { BIS_WL_westOwnedVehicles };
				case east: { BIS_WL_eastOwnedVehicles };
				case independent: { BIS_WL_guerOwnedVehicles };
				default { [] };
			};
		};

		_sideVehicles = _sideVehicles select {
			private _parent = objectParent _x;
			isNull _parent || _parent isKindOf "Steerable_Parachute_F";
		} select {
			WL_ISUP(_x)
		};
		_mapData set ["sideVehicles", _sideVehicles];

		private _targetsOnDatalink = (listRemoteTargets _side) select {
			WL_ISUP(_x # 0)
		} select {
			(_x # 1) >= -10
		} select {
			private _targetSide = [_x # 0] call WL2_fnc_getAssetSide;
			_targetSide != _side
		} select {
            !(_x # 0 isKindOf "LaserTarget")
        } apply { _x # 0 };
		_mapData set ["scannedUnits", _targetsOnDatalink];

		private _advancedMines = _sideVehicles select {
			_x getVariable ["WL2_smartMinesAP", 0] > 0 || _x getVariable ["WL2_smartMinesAT", 0] > 0
		};
		_mapData set ["advancedMines", _advancedMines];

		private _enemyUnits = switch (_side) do {
			case west: { BIS_WL_eastOwnedVehicles + BIS_WL_guerOwnedVehicles };
			case east: { BIS_WL_westOwnedVehicles + BIS_WL_guerOwnedVehicles };
			case independent: { BIS_WL_westOwnedVehicles + BIS_WL_eastOwnedVehicles };
			default { [] };
		};

		private _visibleEnemyUnits = _enemyUnits select {
			WL_ISUP(_x)
		} select {
			private _assetActualType = WL_ASSET_TYPE(_x);
			private _showToEnemies = WL_ASSET_FIELD(_assetData, _assetActualType, "showToEnemies", 0);
			_showToEnemies > cameraOn distance2D _x
		} select {
			!(_x in _targetsOnDatalink)
		};
		_mapData set ["visibleEnemyUnits", _visibleEnemyUnits];

		private _combatPatrolSectors = BIS_WL_allSectors select {
			_x getVariable ["WL2_combatAirActive", false];
		};

		private _forwardBases = missionNamespace getVariable ["WL2_forwardBases", []];
		private _capForwardAirbases = _forwardBases select {
			private _defenseLevel = _x getVariable ["WL2_forwardBaseDefenseLevel", 0];
			_defenseLevel > 3;
		} select {
			_x getVariable ["WL2_combatAirActive", false];
		};
		_mapData set ["combatAirAreas", _combatPatrolSectors + _capForwardAirbases];

		private _airWrecks = allDead select {
			_x isKindOf "Air"
		} select {
			_x distance2D cameraOn < 4000
		} select {
			private _attachment = attachedTo _x;
			if (isNull _attachment) then {
				true;
			} else {
				if (_attachment isKindOf "I_TargetSoldier") then {
					isNull ropeAttachedTo _attachment;
				} else {
					false;
				};
			};
		};
		_mapData set ["airWrecks", _airWrecks];

		private _visibleUnits = _sideVehicles + _targetsOnDatalink + _visibleEnemyUnits;

		private _minefields = _visibleUnits select {
			private _mineData = _x getVariable ["WL2_minefield", []];
			count _mineData > 0;
		};
		_mapData set ["minefields", _minefields];

		private _scanners = _visibleUnits select {
			_x getVariable ["WL_scanRadius", -1] > 0
		};
		_mapData set ["scanners", _scanners];

		private _isMapBeingDrawn = uiNamespace getVariable ["WL2_drawingMap", false];
		if (_isMapBeingDrawn) then {
			private _mapColorCache = createHashMap;
			private _mapIconCache = createHashMap;
			private _mapSizeCache = createHashMap;
			private _mapTextCache = createHashMap;
			private _mapTextDetailedCache = createHashMap;
			{
				private _color = [_x, _mapColorCache] call WL2_fnc_iconColor;
				private _iconType = [_x, _mapIconCache] call WL2_fnc_iconType;
				private _size = [_x, _mapSizeCache] call WL2_fnc_iconSize;

				private _text = [_x, _mapTextCache, false] call WL2_fnc_iconText;
				private _textDetailed = [_x, _mapTextDetailedCache, true] call WL2_fnc_iconText;

				_x setVariable ["WL2_mapIconColor", _color];
				_x setVariable ["WL2_mapIconType", _iconType];
				_x setVariable ["WL2_mapIconSize", _size];

				_x setVariable ["WL2_mapIconText", _text];
				_x setVariable ["WL2_mapIconTextDetailed", _textDetailed];
			} forEach _visibleUnits;
		};

		private _sectorMarkerThreshold = _settingsMap getOrDefault ["sectorMarkerTextThreshold", 0.4];
		_sectorMarkerThreshold = linearConversion [0, 1, _sectorMarkerThreshold, -3, 0];
		_sectorMarkerThreshold = 10 ^ _sectorMarkerThreshold;
		_mapData set ["sectorMarkerThreshold", _sectorMarkerThreshold];

		private _teamSectorMarkers = [];
		private _allSectorMarkers = [];
		{
			private _sector = _x;
			private _sectorMarkerTeam = [_sector, _side] call WL2_fnc_sectorButtonMarker;
			private _sectorMarkerEnemy = [_sector, BIS_WL_enemySide] call WL2_fnc_sectorButtonMarker;

			private _revealedBy = _sector getVariable ["BIS_WL_revealedBy", []];

			if (_sectorMarkerTeam # 1 != "None") then {
				_teamSectorMarkers pushBack [_sector, _sectorMarkerTeam];
			};
			if (_sectorMarkerEnemy # 1 != "None") then {
				_allSectorMarkers pushBack [_sector, _sectorMarkerEnemy];
			};
		} forEach BIS_WL_allSectors;
		_mapData set ["teamSectorMarkers", _teamSectorMarkers];
		_mapData set ["enemySectorMarkers", _allSectorMarkers];

		private _munitionList = cameraOn getVariable ["DIS_munitionList", []];
		_munitionList = _munitionList select { alive _x };
		_mapData set ["trackedProjectiles", _munitionList];

		private _capAreaModifiers = missionNamespace getVariable ["WL2_capAreaModifiers", [0, 0, 0]];
		private _sideIndex = if (_side == west) then { 0 } else { 1 };
		private _otherSideIndex = if (_side == west) then { 1 } else { 0 };
		private _controlledMod = _capAreaModifiers # _sideIndex;
		private _enemyMod = _capAreaModifiers # _otherSideIndex;

		private _controlledAreas = missionNamespace getVariable ["WL2_controlledAreas", [0, 0]];
		private _controlledArea = _controlledAreas # _sideIndex;
		private _enemyControlledArea = _controlledAreas # _otherSideIndex;

		private _areaControlData = [
			format ["    %1 km² (Capture +%2x)", (_controlledArea / 1e6) toFixed 1, _controlledMod toFixed 1],
			format ["    ~%1 km² (Capture +%2x)", round (_enemyControlledArea / 1e6), _enemyMod toFixed 1]
		];
		_mapData set ["areaControlData", _areaControlData];

		private _teamColor = switch (_side) do {
			case west: { [0, 0.3, 0.6, 0.8] };
			case east: { [0.5, 0, 0, 0.8] };
			case independent: { [0, 0.6, 0, 0.8] };
			default { [0.4, 0, 0.5, 0.8] };
		};
		_mapData set ["teamColor", _teamColor];

		uiSleep 1;
	};
};

// Fast loop
0 spawn {
	private _settingsMap = missionProfileNamespace getVariable ["WL2_settings", createHashMap];
	while { !BIS_WL_missionEnd } do {
		if (WL_IsReplaying) then {
			uiSleep 5;
			continue;
		};

		private _refreshRate = _settingsMap getOrDefault ["mapRefresh", 10];
		_refreshRate = _refreshRate max 1;
		private _refreshSleepTime = 1 / _refreshRate;

		private _isMapBeingDrawn = uiNamespace getVariable ["WL2_drawingMap", false];
		if (!_isMapBeingDrawn) then {
			uiSleep _refreshSleepTime;
			continue;
		};

		private _isSpectator = WL_IsSpectator;
		private _mainMap = if (_isSpectator) then {
			(findDisplay 11012) displayCtrl 5503
		} else {
			(findDisplay 12) displayCtrl 51
		};
		private _drawMode = if (_isSpectator) then { 1 } else { 0 };
		[_mainMap, _drawMode] call WL2_fnc_iconDrawMapPrepare;

		uiNamespace setVariable ["BIS_WL_mapControl", _mainMap];

		uiNamespace setVariable ["WL2_drawingMap", false];
		uiSleep _refreshSleepTime;
	};
};

#if WL_REPLAYS
// Store game data
0 spawn {
	missionNamespace setVariable ["WL2_drawIcons", []];
	missionNamespace setVariable ["WL2_drawEllipses", []];
	missionNamespace setVariable ["WL2_drawSemiCircles", []];
	missionNamespace setVariable ["WL2_drawRectangles", []];
	missionNamespace setVariable ["WL2_drawPolygons", []];
	missionNamespace setVariable ["WL2_drawSectorIcons", []];

	while { !BIS_WL_missionEnd } do {
		private _mainMap = (findDisplay 12) displayCtrl 51;
		[_mainMap, 2] call WL2_fnc_iconDrawMapPrepare;
		uiSleep 30;
	};
};
#endif