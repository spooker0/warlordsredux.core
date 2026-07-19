#include "includes.inc"
params ["_sector", "_owner"];

if (isDedicated) exitWith {};
if (isNull _sector) exitWith {};

if (_sector getVariable ["WL2_name", "Sector"] in WL_SPECIAL_SECTORS) exitWith {};

private _ownerIndex = [west, east, independent] find _owner;
private _capturableBySides = _sector getVariable ["WL2_capturableBySides", []];
private _sectorMarkers = _sector getVariable ["BIS_WL_markers", ["", ""]];
_sectorMarkers params [["_mrkrMain", ""], ["_mrkrArea", ""]];

if (_mrkrArea == "") exitWith {};
if (_mrkrMain == "") exitWith {};

private _canSeeAll = WL_IsSpectator || WL_IsReplaying;
private _side = BIS_WL_playerSide;
if (_owner == _side || _side in _capturableBySides || _sector == WL_TARGET_FRIENDLY || _canSeeAll) then {
	_mrkrArea setMarkerBrushLocal "Border";
} else {
	_mrkrArea setMarkerBrushLocal "Solid";
};

private _sectorServices = _sector getVariable ["WL2_services", []];
if (_side in (_sector getVariable ["BIS_WL_revealedBy", []]) || _side == independent || _canSeeAll) then {
	if (_sector in WL_BASES) then {
		_mrkrMain setMarkerTypeLocal (["flag_NATO", "flag_CSAT", "flag_Altis"] select _ownerIndex);
		_mrkrMain setMarkerColorLocal "ColorWhite";
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
		_mrkrMain setMarkerTypeLocal _sectorIcon;

		private _teamSectorsData = WL_SECTORS_DATA(_side);
		private _unavailable = _teamSectorsData getOrDefault ["unavailable", []];
		if (_sector in _unavailable) then {
			_mrkrMain setMarkerColorLocal "ColorGrey";
		} else {
			_mrkrMain setMarkerColorLocal (["colorBLUFOR", "colorOPFOR", "colorIndependent"] select _ownerIndex);
		};
	};
	_mrkrMain setMarkerShadowLocal false;
} else {
	_mrkrMain setMarkerColorLocal "ColorUnknown";
	private _sectorIcon = if ("A" in _sectorServices) then {
		"n_uav";
	} else {
		if ("H" in _sectorServices) then {
			"n_air";
		} else {
			"n_unknown";
		};
	};
	_mrkrMain setMarkerTypeLocal _sectorIcon;
	_mrkrMain setMarkerShadowLocal false;

	_mrkrArea setMarkerColorLocal "ColorGrey";
};

call WL2_fnc_updateSectorsData;