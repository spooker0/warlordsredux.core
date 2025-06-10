#include "includes.inc"
params ["_mode", ["_side", sideUnknown]];

private _respawnMarkersCount = 20;
switch (_mode) do {
	case "setup": {
		_spawnMarkers = {
			_sideID = ["west", "east", "guerrila"] select (BIS_WL_sidesArray find _this);
			_respawnMarkerFormat = format ["respawn_%1_", _sideID];
			_base = _this call WL2_fnc_getSideBase;
			_baseSpots = [_base, 0, true] call WL2_fnc_findSpawnPositions;
			_baseSpotsCnt = count _baseSpots;
			if (_baseSpotsCnt > _respawnMarkersCount) then {
				_baseSpots resize _respawnMarkersCount;
			};

			_i = 1;
			for "_i" from 1 to _respawnMarkersCount do {
				createMarkerLocal [_respawnMarkerFormat + str _i, if (_baseSpotsCnt == _respawnMarkersCount) then {_baseSpots # _i} else {selectRandom _baseSpots}];
			};
		};
		if (isServer) then {
			{_x call _spawnMarkers} forEach BIS_WL_competingSides;
		} else {
			BIS_WL_playerSide call _spawnMarkers;
		};
	};
	case "base_vulnerable": {
		_sideID = ["west", "east", "guerrila"] select (BIS_WL_sidesArray find _side);
		_respawnMarkerFormat = format ["respawn_%1_", _sideID];
		_base = _side call WL2_fnc_getSideBase;
		_baseArea = +(_base getVariable "WL2_objectArea");
		_markerLocArr = [[_base, (_baseArea # 0) + WL_BASE_DANGER_SPAWN_RANGE, (_baseArea # 1) + WL_BASE_DANGER_SPAWN_RANGE, _baseArea # 2, _baseArea # 3], 50] call WL2_fnc_findSpawnPositions;

		_i = 1;
		for "_i" from 1 to _respawnMarkersCount do {
			_mrkr = (_respawnMarkerFormat + str _i);
			_mrkr setMarkerPosLocal (if (count _markerLocArr >= 5) then {selectRandom _markerLocArr} else {[_base, WL_BASE_DANGER_SPAWN_RANGE, random 360] call BIS_fnc_relPos});
		};
	};
	case "base_safe": {
		_sideID = ["west", "east", "guerrila"] select (BIS_WL_sidesArray find _side);
		_respawnMarkerFormat = format ["respawn_%1_", _sideID];
		_base = _side call WL2_fnc_getSideBase;
		_baseSpots = [_base, 0, true] call WL2_fnc_findSpawnPositions;

		_i = 1;
		for "_i" from 1 to _respawnMarkersCount do {
			_mrkr = (_respawnMarkerFormat + str _i);
			_mrkr setMarkerPosLocal (if (count _baseSpots >= 5) then {selectRandom _baseSpots} else {[_base, random 50, random 360] call BIS_fnc_relPos});
		};
	};
};