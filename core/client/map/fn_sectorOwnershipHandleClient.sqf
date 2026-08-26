#include "includes.inc"
params ["_sector", "_owner", "_previousOwner"];

if (isNil "BIS_WL_playerSide") exitWith {};

private _playerSide = BIS_WL_playerSide;
if (_owner == BIS_WL_enemySide) then {
	if (_sector in WL_BASES) then {
		"Defeat" call WL2_fnc_announcer;
	} else {
		if (_playerSide == _previousOwner) then {
			"Lost" call WL2_fnc_announcer;
		} else {
			private _sectorRevealedSides = _sector getVariable ["BIS_WL_revealedBy", []];
			if (_playerSide in _sectorRevealedSides) then {
				"Enemy_advancing" call WL2_fnc_announcer;
			};
		};

		private _message = format [
			localize "STR_A3_WL_popup_sector_seized",
			_sector getVariable ["WL2_name", "Sector"],
			_owner call WL2_fnc_sideToFaction
		];
		[_message] call WL2_fnc_smoothText;
	};
};
if (_owner == _playerSide) then {
	if (_sector in WL_BASES) then {
		"Victory" call WL2_fnc_announcer;
	} else {
		"Seized" call WL2_fnc_announcer;
	};
};

call WL2_fnc_updateSectorsData;
[_sector, _owner] call WL2_fnc_sectorMarkerUpdate;

{
	[_x, _x getVariable ["BIS_WL_owner", independent]] call WL2_fnc_sectorMarkerUpdate;
} forEach (BIS_WL_allSectors select {_x != _sector});