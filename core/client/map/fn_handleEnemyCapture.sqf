#include "includes.inc"
private _playerSide = side group player;

while { !BIS_WL_missionEnd } do {
	uiSleep 1;
	private _ownedSectors = BIS_WL_sectorsArray select 0;
	{
		private _sector = _x;
		private _captureProgress = _sector getVariable ["BIS_WL_captureProgress", 0];
		private _owner = _sector getVariable ["BIS_WL_owner", independent];

		private _marker = (_sector getVariable ["BIS_WL_markers", []]) # 1;
		if (_captureProgress > 0 && _owner == _playerSide) then {
			_marker setMarkerBrushLocal "Solid";
			_marker setMarkerColorLocal BIS_WL_colorMarkerEnemy;
		} else {
			_marker setMarkerBrushLocal "Border";
			_marker setMarkerColorLocal BIS_WL_colorMarkerFriendly;
		};
	} forEach _ownedSectors;
};