#include "includes.inc"
addMissionEventHandler ["Map", {
	params ["_mapIsOpened", "_mapIsForced"];
	if (WL_IsReplaying) exitWith {};

	if (!_mapIsOpened) then {
		deleteMarkerLocal "WL2_sectorStrongholdMarker";
		["Map"] spawn WL2_fnc_showHint;
		0 spawn {
			uiSleep 1;
			BIS_WL_highlightedSector = objNull;
			WL_SectorActionTarget = objNull;

			private _mapButtonDisplay = uiNamespace getVariable ["WL2_mapButtonDisplay", displayNull];
			if (!isNull _mapButtonDisplay) then {
				_mapButtonDisplay closeDisplay 1;
			};

			private _allMaps = uiNamespace getVariable ["WL2_allMaps", []];
			{
				[[], _x] call WL2_fnc_handleSectorIcons;
			} forEach _allMaps;
		};
	} else {
		private _mapLayerParams = ["MAP LAYERS", [
			["Detailed info", "lookAround"],
			["Circle tool", "headlights"],
			["Circle radius -", "ListLeftVehicleDisplay"],
			["Circle radius +", "ListRightVehicleDisplay"],
			[localize "STR_WL_mapMode", "nightVision"]
		]];
		["Map", _mapLayerParams] spawn WL2_fnc_showHint;
		uiNamespace setVariable ["WL2_mapMode", 0];

		private _playerMarkers = allMapMarkers select {
			"_USER_DEFINED #" in _x
		};

		private _playerIds = createHashMap;
		{
			_playerIds set [getPlayerID _x, _x];
		} forEach allPlayers;
		{
			private _marker = _x;
			private _markerParams = (_marker select [15]) splitString "/";
			private _playerId = _markerParams select 0;

			private _playerForMarker = _playerIds getOrDefault [_playerId, objNull];
			if (isNull _playerForMarker) then {
				deleteMarker _marker;
			};
			if (side group _playerForMarker == BIS_WL_playerSide) then {
				_marker setMarkerAlphaLocal 1;
			} else {
				_marker setMarkerAlphaLocal 0;
			};
		} forEach _playerMarkers;
	};
}];