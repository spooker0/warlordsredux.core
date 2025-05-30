#include "..\..\warlords_constants.inc"

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
			};
		} forEach _maps;

		uiSleep 3;
	};
};

// Refresh unit loop
0 spawn {
	private _mapData = createHashMap;
	missionNamespace setVariable ["WL2_mapData", _mapData];
	while { !BIS_WL_missionEnd } do {
		private _side = BIS_WL_playerSide;
		_mapData set ["side", _side];

		private _targetsOnDatalink = (listRemoteTargets _side) select {
            private _target = _x # 0;
            private _targetSide = [_target] call WL2_fnc_getAssetSide;

            private _targetTime = _x # 1;
            _targetTime >= -10 && _targetSide != _side && alive _target && !(_target isKindOf "LaserTarget")
        } apply { _x # 0 };
		_mapData set ["scannedUnits", _targetsOnDatalink];

		private _vehicles = vehicles select { alive _x };
		private _activeVehicles = _vehicles select { isEngineOn _x };
		private _mobileRadars = "Land_MobileRadar_01_radar_F" allObjects 0;
		_mobileRadars = _mobileRadars select {
			_x getVariable ["WL_ewNetActive", false] ||
			_x getVariable ["WL_ewNetActivating", false]
		};
		private _ewNetworkUnits = _activeVehicles + _mobileRadars;
		_mapData set ["ewNetworks", _ewNetworkUnits];

		private _scannerUnits = _activeVehicles select {
			_x getVariable ["WL_scannerOn", false]
		};
		_mapData set ["scannersAll", _scannerUnits];

		private _scannerUnitTeam = _scannerUnits select {
			([_x] call WL2_fnc_getAssetSide) == _side
		};
		_mapData set ["scannersTeam", _scannerUnitTeam];

		private _allPlayers = allPlayers;

		private _teamPlayers = _allPlayers select { side group _x == _side };
		private _deadPlayers = _teamPlayers select { !alive _x };
		_mapData set ["deadPlayers", _deadPlayers];

		private _deadPlayersAll = _allPlayers select { !alive _x };
		_mapData set ["deadPlayersAll", _deadPlayersAll];

		private _teammates = _teamPlayers select { isNull objectParent _x } select { alive _x } select { !isObjectHidden _x };
		_mapData set ["teammates", _teammates];

		private _livePlayersAll = _allPlayers select { isNull objectParent _x } select { alive _x } select { !isObjectHidden _x };
		_mapData set ["livePlayersAll", _livePlayersAll];

		private _aiInVehicle = allUnits select { alive _x }
			select { isNull objectParent _x }
			select { typeOf _x != "Logic" }
			select { !isPlayer _x };

		_mapData set ["aiInVehicleAll", _aiInVehicle];

		_aiInVehicleTeam = _aiInVehicle select { side group (crew _x select 0) == _side };
		_mapData set ["aiInVehicle", _aiInVehicleTeam];

		private _playerAi = (units player) select { _x != player } select { alive _x } select { isNull objectParent _x };
		_mapData set ["playerAi", _playerAi];

		private _allSquadmates = ["getAllInSquad"] call SQD_fnc_client;
		_allSquadmates = _allSquadmates apply { vehicle _x };
		_mapData set ["allSquadmates", _allSquadmates];

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
		private _vehiclesOnSide = _vehicles select { count crew _x > 0 } select { side _x == _side };
		_sideVehicles insert [-1, _vehiclesOnSide, true];
		_mapData set ["sideVehicles", _sideVehicles];

		private _sideVehiclesAll = _vehicles select { simulationEnabled _x } select { !(_x isKindOf "LaserTarget") } select {
			private _targetSide = [_x] call WL2_fnc_getAssetSide;
			_targetSide in [west, east, independent]
		};
		_mapData set ["sideVehiclesAll", _sideVehiclesAll];

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

			if (_sectorMarkerTeam # 1 != "NONE") then {
				_teamSectorMarkers pushBack [_sector, _sectorMarkerTeam];
			};
			if (_sectorMarkerEnemy # 1 != "NONE") then {
				_allSectorMarkers pushBack [_sector, _sectorMarkerEnemy];
			};
		} forEach BIS_WL_allSectors;
		_mapData set ["teamSectorMarkers", _teamSectorMarkers];
		_mapData set ["enemySectorMarkers", _allSectorMarkers];

		uiSleep 0.5;
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

		private _mainMap = (findDisplay 12) displayCtrl 51;
		private _drawMode = if (WL_IsSpectator) then { 1 } else { 0 };
		[WL_CONTROL_MAP, _drawMode] spawn WL2_fnc_iconDrawMapPrepare;

		private _refreshRate = _settingsMap getOrDefault ["mapRefresh", 4];
		_refreshRate = _refreshRate max 1;
		private _refreshSleepTime = 1 / _refreshRate;
		uiSleep _refreshSleepTime;
	};
};

#if WL_REPLAYS
// Store game data
0 spawn {
	missionNamespace setVariable ["WL2_drawIcons", []];
	missionNamespace setVariable ["WL2_drawEllipses", []];
	missionNamespace setVariable ["WL2_drawSectorIcons", []];

	while { !BIS_WL_missionEnd } do {
		private _mainMap = (findDisplay 12) displayCtrl 51;
		[_mainMap, 2] spawn WL2_fnc_iconDrawMapPrepare;
		sleep 30;
	};
};
#endif