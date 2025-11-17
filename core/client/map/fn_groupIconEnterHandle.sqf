#include "includes.inc"
params ["_is3D", "_group"];

private _map = uiNamespace getVariable ["BIS_WL_mapControl", controlNull];
if (isNull _map) exitWith {};

private _groupNextRenderTime = _group getVariable ["WL2_groupNextRenderTime", 0];
if (_groupNextRenderTime > serverTime) exitWith {};
_group setVariable ["WL2_groupNextRenderTime", serverTime + 1];

private _sector = _group getVariable ["BIS_WL_sector", objNull];

private _conditions = [
	"fastTravelSeized",
	"fastTravelConflict",
	"airAssault",
	"vehicleParadrop",
	"scan"
];
private _sectorHasOptions = false;
{
	private _condition = _x;
	private _eligible = [_sector, _condition] call WL2_fnc_mapButtonConditions;
	if (_eligible == "ok") then {
		_sectorHasOptions = true;
	};
} forEach _conditions;
WL_SectorActionTargetActive = _sectorHasOptions;

if (isNull _sector) exitWith {
	BIS_WL_highlightedSector = objNull;
};

private _selectionActive = BIS_WL_currentSelection in [
	WL_ID_SELECTION_ORDERING_AIRCRAFT,
	WL_ID_SELECTION_FAST_TRAVEL,
	WL_ID_SELECTION_FAST_TRAVEL_CONTESTED,
	WL_ID_SELECTION_FAST_TRAVEL_VEHICLE,
	WL_ID_SELECTION_FAST_TRAVEL_STRONGHOLD,
	WL_ID_SELECTION_SCAN
];
private _votingActive = WL_VotePhase != 0;
private _services = _sector getVariable ["WL2_services", []];

private _side = BIS_WL_playerSide;

private _lastScan = (_sector getVariable ["WL2_lastScanned", -9999]);
private _scanCD = (_lastScan + WL_COOLDOWN_SCAN - serverTime) max 0;
private _currentScannedSectors = missionNamespace getVariable ["WL2_scanningSectors", []];
private _isScanning = _sector in _currentScannedSectors;

private _getTeamColor = {
	params ["_team"];
	[
		[0, 0.3, 0.6, 1],
		[0.5, 0, 0, 1],
		[0, 0.5, 0, 1]
	] # ([west, east, independent] find _team);
};

private _percentage = _sector getVariable ["BIS_WL_captureProgress", 0];
private _revealed = _side in (_sector getVariable ["BIS_WL_revealedBy", []]);
if (!_revealed) then {
	_percentage = 0;
};

private _servicesText = [];
if ("A" in _services) then {
	_servicesText pushBack localize "STR_A3_WL_param32_title";
};
if ("H" in _services) then {
	_servicesText pushBack localize "STR_A3_WL_module_service_helipad";
};
if ("W" in _services) then {
	_servicesText pushBack localize "STR_A3_WL_param30_title";
};

private _scanCooldown = if (_isScanning) then {
	["Scan active", [0, 1, 0, 1]]
} else {
	if (_scanCD > 0) then {
		[
			format ["%1: %2", localize "STR_A3_WL_param_scan_timeout", [ceil _scanCD, "MM:SS"] call BIS_fnc_secondsToString],
			[1, 0, 0, 1]
		];
	} else {
		""
	};
};

private _fortification = if (_revealed) then {
	private _previousOwners = _sector getVariable ["BIS_WL_previousOwners", []];
	if (count _previousOwners > 1) then {
		private _fortificationTime = _sector getVariable ["WL_fortificationTime", -1];
		private _fortificationETA = ceil (_fortificationTime - serverTime);
		_fortificationETA = _fortificationETA max 0;
		[
			format ["Fortifying %1", [_fortificationETA, "MM:SS"] call BIS_fnc_secondsToString],
			[0.4, 0, 0.5, 1]
		]
	} else {
		""
	}
} else {
	""
};

private _sectorName = _sector getVariable ["WL2_name", "Sector"];
private _sectorIncome = if !(_sectorName in WL_SPECIAL_SECTORS) then {
	[
		WL_MoneySign,
		_sector getVariable "BIS_WL_value",
		"/",
		localize "STR_A3_rscmpprogress_min"
	] joinString ""
} else {
	""
};

private _sectorInfo = [
	_sectorName,
	_sectorIncome,
	(_servicesText joinString ", "),
	_scanCooldown,
	_fortification
];
_sectorInfo = _sectorInfo select {
	if (_x isEqualType "") then {
		_x != ""
	} else {
		count _x > 0
	};
};
_sector setVariable ["WL2_sectorInfo", _sectorInfo];

WL_SectorActionTarget = _sector;
call WL2_fnc_updateSelectionState;

if !(_selectionActive || _votingActive) exitWith {
	BIS_WL_highlightedSector = objNull;
};

if (_sector in BIS_WL_selection_availableSectors) then {
	BIS_WL_highlightedSector = _sector;
	if !(BIS_WL_hoverSamplePlayed) then {
		playSound "clickSoft";
		BIS_WL_hoverSamplePlayed = true;
	};
} else {
	BIS_WL_highlightedSector = objNull;
};