#include "includes.inc"

private _blinkingSectors = [];
private _blinking = false;
private _nextPossibleWarn = 0;
private _playerSide = side group player;

while { !BIS_WL_missionEnd } do {
	_blinking = !_blinking;
	sleep 1;

	if (_blinking) then {
		{
			private _sector = _x;
			private _color = if (_sector getVariable ["BIS_WL_owner", independent] == _playerSide) then {
				BIS_WL_colorMarkerFriendly
			} else {
				BIS_WL_colorMarkerEnemy
			};
			private _marker = (_sector getVariable ["BIS_WL_markers", []]) # 1;
			_marker setMarkerBrushLocal "Border";
			_marker setMarkerColorLocal _color;
		} forEach _blinkingSectors;

		_blinkingSectors = [];
	} else {
		private _ownedSectors = BIS_WL_sectorsArray select 0;

		private _shouldWarn = false;
		{
			private _sector = _x;
			private _captureProgress = _sector getVariable ["BIS_WL_captureProgress", 0];
			private _owner = _sector getVariable ["BIS_WL_owner", independent];

			if (_captureProgress > 0 && _owner == _playerSide) then {
				_blinkingSectors pushBack _sector;
				private _marker = (_sector getVariable ["BIS_WL_markers", []]) # 1;
				_marker setMarkerBrushLocal "Solid";
				_marker setMarkerColorLocal BIS_WL_colorMarkerEnemy;
				_shouldWarn = true;
			};
		} forEach _ownedSectors;

		if (_shouldWarn && serverTime > _nextPossibleWarn) then {
			_nextPossibleWarn = serverTime + 60;
			"under_attack" call WL2_fnc_announcer;
		};
	};
};