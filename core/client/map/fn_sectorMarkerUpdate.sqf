#include "includes.inc"
params ["_sector", "_owner"];

if (isDedicated) exitWith {};
if (isNull _sector) exitWith {};

if (_sector getVariable ["WL2_name", "Sector"] in WL_SPECIAL_SECTORS) exitWith {};

private _ownerIndex = [west, east, independent] find _owner;
private _capturableBySides = _sector getVariable ["WL2_capturableBySides", []];

private _markerMain = _sector getVariable ["WL2_markerMain", ""];
if (_markerMain == "") exitWith {};

private _markerArea = _sector getVariable ["WL2_markerArea", ""];
if (_markerArea == "") exitWith {};

private _canSeeAll = WL_IsSpectator || WL_IsReplaying;
private _side = BIS_WL_playerSide;
if (_owner == _side || _side in _capturableBySides || _sector == WL_TARGET_FRIENDLY || _canSeeAll) then {
	_markerArea setMarkerBrushLocal "Border";
} else {
	_markerArea setMarkerBrushLocal "Solid";
};

private _sectorServices = _sector getVariable ["WL2_services", []];
if (_side in (_sector getVariable ["BIS_WL_revealedBy", []]) || _side == independent || _canSeeAll) then {
	if (_sector in WL_BASES) then {
		_markerMain setMarkerTypeLocal (["flag_NATO", "flag_CSAT", "flag_Altis"] select _ownerIndex);
		_markerMain setMarkerColorLocal "ColorWhite";
	} else {
		private _sectorIcon = if ("A" in _sectorServices) then {
			["b_uav", "o_uav", "n_uav"] select _ownerIndex;
		} else {
			if ("H" in _sectorServices) then {
				["b_air", "o_air", "n_air"] select _ownerIndex;
			} else {
				["b_installation", "o_installation", "n_installation"] select _ownerIndex;
			};
		};
		_markerMain setMarkerTypeLocal _sectorIcon;

		private _teamSectorsData = WL_SECTORS_DATA(_side);
		private _unavailable = _teamSectorsData getOrDefault ["unavailable", []];
		if (_sector in _unavailable) then {
			_markerMain setMarkerColorLocal "ColorGrey";
		} else {
			_markerMain setMarkerColorLocal (["colorBLUFOR", "colorOPFOR", "colorIndependent"] select _ownerIndex);
		};
	};
	_markerMain setMarkerShadowLocal false;
} else {
	_markerMain setMarkerColorLocal "ColorUnknown";
	private _sectorIcon = if ("A" in _sectorServices) then {
		"n_uav";
	} else {
		if ("H" in _sectorServices) then {
			"n_air";
		} else {
			"n_unknown";
		};
	};
	_markerMain setMarkerTypeLocal _sectorIcon;
	_markerMain setMarkerShadowLocal false;

	_markerArea setMarkerColorLocal "ColorGrey";
};

call WL2_fnc_updateSectorsData;