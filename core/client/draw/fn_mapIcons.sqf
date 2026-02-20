#include "includes.inc"
// Slow loop
0 spawn {
	while { !BIS_WL_missionEnd } do {
		private _mainMap = (findDisplay 12) displayCtrl 51;
		private _maps = [
			_mainMap,
			(findDisplay 160) displayCtrl 51,
			(findDisplay -1) displayCtrl 500
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

		uiNamespace setVariable ["WL2_mapColorCache", createHashMap];
		uiNamespace setVariable ["WL2_mapIconCache", createHashMap];
		uiNamespace setVariable ["WL2_mapTextCache", createHashMap];
		uiNamespace setVariable ["WL2_mapSizeCache", createHashMap];

		// player icon cache
		uiNamespace setVariable ["WL2_playerIconTextCache", createHashMap];
		uiNamespace setVariable ["WL2_playerIconColorCache", createHashMap];

		uiSleep 3;
	};
};

// Refresh unit loop
0 spawn {
	private _mapData = createHashMap;
	private _assetData = WL_ASSET_DATA;
	missionNamespace setVariable ["WL2_mapData", _mapData];
	private _playerId = getPlayerID player;

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

		private _vehicles = vehicles select { alive _x };
		private _activeVehicles = +_vehicles;
		_activeVehicles append ("Land_MobileRadar_01_radar_F" allObjects 0);
		private _ewNetworkUnits = _activeVehicles select {
			_x getVariable ["WL_ewNetActive", false] ||
			_x getVariable ["WL_ewNetActivating", false]
		};
		_mapData set ["ewNetworks", _ewNetworkUnits];

		private _strongholds = missionNamespace getVariable ["WL_strongholds", []];
		private _visibleStrongholds = _strongholds select {
			private _sector = _x getVariable ["WL_strongholdSector", objNull];
			private _sectorOwner = _sector getVariable ["BIS_WL_owner", independent];
			BIS_WL_playerSide == _sectorOwner || _sector == WL_TARGET_FRIENDLY
		};
		_mapData set ["strongholds", _visibleStrongholds];

		private _scannerUnits = _activeVehicles select {
			_x getVariable ["WL_scannerOn", false]
		};
		_mapData set ["scannersAll", _scannerUnits];

		private _scannerUnitTeam = _scannerUnits select {
			if (([_x] call WL2_fnc_getAssetSide) == _side) then {
				true
			} else {
				if (_x distance cameraOn < 2000) then {
					private _assetActualType = WL_ASSET_TYPE(_x);
					WL_ASSET_FIELD(_assetData, _assetActualType, "hasScanner", 0) == 1
				} else {
					false
				};
			};
		};
		_mapData set ["scannersTeam", _scannerUnitTeam];

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
			isNull objectParent _x
		};
		_mapData set ["sideVehicles", _sideVehicles];

		private _alwaysShowEwUnits = _ewNetworkUnits apply {
			[_x, 10]
		};
		private _targetsOnDatalink = (_alwaysShowEwUnits + listRemoteTargets _side) select {
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

		private _advancedSams = _vehicles select {
			[_x] call WL2_fnc_getAssetSide != _side
		} select {
			count (_x getVariable ["DIS_advancedSamDetectionLocation", []]) > 0
		};
		_mapData set ["advancedSams", _advancedSams];

		private _advancedMines = _sideVehicles select {
			_x getVariable ["WL2_smartMinesAP", 0] > 0 || _x getVariable ["WL2_smartMinesAT", 0] > 0
		};
		_mapData set ["advancedMines", _advancedMines];

		private _rallyPoints = missionNamespace getVariable ["WL2_rallyPoints", []];
		_rallyPoints = _rallyPoints select { alive _x };
		_mapData set ["rallyPoints", _rallyPoints];

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
			_showToEnemies > cameraOn distance _x
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
		};
		_mapData set ["airWrecks", _airWrecks];

		private _minefields = (_sideVehicles + _targetsOnDatalink + _visibleEnemyUnits) select {
			_x getVariable ["WL2_isMinefield", false];
		};
		_mapData set ["minefields", _minefields];

		private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];
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

		uiSleep 1;
	};
};

// Fast loop
0 spawn {
	private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];
	while { !BIS_WL_missionEnd } do {
		if (WL_IsReplaying) then {
			uiSleep 5;
			continue;
		};

		private _refreshRate = _settingsMap getOrDefault ["mapRefresh", 4];
		_refreshRate = _refreshRate max 1;
		private _refreshSleepTime = 1 / _refreshRate;

		private _isMapBeingDrawn = uiNamespace getVariable ["WL2_drawingMap", false];
		if (!_isMapBeingDrawn) then {
			uiSleep _refreshSleepTime;
			continue;
		};

		private _mainMap = (findDisplay 12) displayCtrl 51;
		private _drawMode = if (WL_IsSpectator) then { 1 } else { 0 };
		[WL_CONTROL_MAP, _drawMode] call WL2_fnc_iconDrawMapPrepare;

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