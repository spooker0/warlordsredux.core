#include "..\..\warlords_constants.inc"

params ["_sector", "_owner"];

if (isDedicated) exitWith {};

if (_sector getVariable ["WL2_name", "Sector"] == "Wait") exitWith {};

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

if (BIS_WL_playerSide in (_sector getVariable ["BIS_WL_revealedBy", []]) || BIS_WL_playerSide == independent || _canSeeAll) then {
	if (_sector in WL_BASES) then {
		_mrkrMain setMarkerSizeLocal [WL_BASE_ICON_SIZE, WL_BASE_ICON_SIZE];
	};
	if (_sector in _specialStateArray) then {
		_mrkrMain setMarkerColorLocal "ColorGrey";
	} else {
		_mrkrMain setMarkerColorLocal (["colorBLUFOR", "colorOPFOR", "colorIndependent"] select _ownerIndex);
	};
	_mrkrArea setMarkerColorLocal (["colorBLUFOR", "colorOPFOR", "colorIndependent"] select _ownerIndex);
	if (_sector in WL_BASES) then {
		_mrkrMain setMarkerTypeLocal (["b_hq", "o_hq", "n_hq"] select _ownerIndex);
	} else {
		private _previousOwners = _sector getVariable ["BIS_WL_previousOwners", []];
		private _vulnerable = count (_previousOwners - [_owner]) > 0 || _sector == WL_TARGET_ENEMY || _sector == WL_TARGET_FRIENDLY;
		if (_vulnerable) then {
			_mrkrMain setMarkerTypeLocal (["b_service", "o_service", "n_installation"] select _ownerIndex);
		} else {
			_mrkrMain setMarkerTypeLocal (["b_installation", "o_installation", "n_installation"] select _ownerIndex);
		};
	};
} else {
	_mrkrMain setMarkerColorLocal "ColorUNKNOWN";
	_mrkrMain setMarkerTypeLocal "u_installation";
	_mrkrArea setMarkerColorLocal "ColorOrange";
};

if (_sector == WL_TARGET_FRIENDLY) then {
	call WL2_fnc_refreshCurrentTargetData;
};

["client", true] call WL2_fnc_updateSectorArrays;