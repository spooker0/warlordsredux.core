#include "includes.inc"

while { !BIS_WL_missionEnd } do {
	uiSleep 1;

	private _playerSide = BIS_WL_playerSide;
	private _friendlyColor = if (_playerSide == west) then { "colorBLUFOR" } else { "colorOPFOR" };
	private _enemyColor = if (_playerSide == west) then { "colorOPFOR" } else { "colorBLUFOR" };

	private _teamSectorsData = WL_SECTORS_DATA(_playerSide);
	private _ownedSectors = _teamSectorsData getOrDefault ["owned", []];
	{
		private _sector = _x;
		private _captureProgress = _sector getVariable ["BIS_WL_captureProgress", 0];
		private _owner = _sector getVariable ["BIS_WL_owner", independent];

		private _markerArea = _sector getVariable ["WL2_markerArea", ""];
		if (_captureProgress > 0 && _owner == _playerSide) then {
			_markerArea setMarkerBrushLocal "Solid";
			_markerArea setMarkerColorLocal _enemyColor;
		} else {
			_markerArea setMarkerBrushLocal "Border";
			_markerArea setMarkerColorLocal _friendlyColor;
		};
	} forEach _ownedSectors;
};