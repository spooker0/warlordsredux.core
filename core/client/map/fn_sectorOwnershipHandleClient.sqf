#include "..\..\warlords_constants.inc"

params ["_sector"];

_owner = _sector getVariable "BIS_WL_owner";
if (_owner == BIS_WL_enemySide) then {
	if (_sector in WL_BASES) then {
		"Defeat" call WL2_fnc_announcer;
	} else {
		if (BIS_WL_playerSide in (_sector getVariable ["BIS_WL_revealedBy", []])) then {
			"Lost" call WL2_fnc_announcer;
		};
	};
};
if (_owner == BIS_WL_playerSide) then {
	if (_sector in WL_BASES) then {
		"Victory" call WL2_fnc_announcer;
	} else {
		"Seized" call WL2_fnc_announcer;
	};
};

"client" call WL2_fnc_updateSectorArrays;
[_sector, _owner] call WL2_fnc_sectorMarkerUpdate;

{
	[_x, _x getVariable "BIS_WL_owner"] call WL2_fnc_sectorMarkerUpdate;
} forEach (BIS_WL_allSectors select {_x != _sector});

if (BIS_WL_playerSide in (_sector getVariable ["BIS_WL_revealedBy", []])) then {
	if (_owner != BIS_WL_playerSide) then {
		"Enemy_advancing" call WL2_fnc_announcer;
	};
	[toUpper format [localize "STR_A3_WL_popup_sector_seized", _sector getVariable "WL2_name", _owner call WL2_fnc_sideToFaction]] spawn WL2_fnc_smoothText;
};