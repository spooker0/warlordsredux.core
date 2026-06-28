#include "includes.inc"
params ["_sector", "_owner"];

if (isDedicated) exitWith {};
if (isNull _sector) exitWith {};

if (_sector getVariable ["WL2_name", "Sector"] in WL_SPECIAL_SECTORS) exitWith {};

private _specialStateArray = if (isNil "BIS_WL_sectorsArray") then { [] } else {
	(BIS_WL_sectorsArray # 6) + (BIS_WL_sectorsArray # 7);
 };

private _ownerIndex = [WEST, EAST, RESISTANCE] find _owner;
private _area = _sector getVariable "WL2_objectArea";
private _previousOwners = _sector getVariable "BIS_WL_previousOwners";
private _mrkrMain = (_sector getVariable "BIS_WL_markers") # 0;
private _mrkrArea = (_sector getVariable "BIS_WL_markers") # 1;

if (isNil "_mrkrArea") exitWith {};

private _canSeeAll = WL_IsSpectator || WL_IsReplaying;
if (_owner == BIS_WL_playerSide || BIS_WL_playerSide in _previousOwners || _sector == WL_TARGET_FRIENDLY || _canSeeAll) then {
	_mrkrArea setMarkerBrushLocal "Border";
} else {
	_mrkrArea setMarkerBrushLocal "Solid";
};

private _sectorServices = _sector getVariable ["WL2_services", []];
if (BIS_WL_playerSide in (_sector getVariable ["BIS_WL_revealedBy", []]) || BIS_WL_playerSide == independent || _canSeeAll) then {
	if (_sector in WL_BASES) then {
	};
	if (_sector in WL_BASES) then {
		_mrkrMain setMarkerTypeLocal (["flag_NATO", "flag_CSAT", "flag_Altis"] select _ownerIndex);
		_mrkrMain setMarkerColorLocal "ColorWhite";
	} else {
		private _previousOwners = _sector getVariable ["BIS_WL_previousOwners", []];
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

		if (_sector in _specialStateArray) then {
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

["client", true] call WL2_fnc_updateSectorArrays;