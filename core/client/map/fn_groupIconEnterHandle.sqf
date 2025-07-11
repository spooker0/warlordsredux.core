#include "includes.inc"
private _map = uiNamespace getVariable ["BIS_WL_mapControl", controlNull];
if (isNull _map) exitWith {};

private _sector = (_this # 1) getVariable ["BIS_WL_sector", objNull];

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
	if ([_sector, _condition] call WL2_fnc_mapButtonConditions) then {
		_sectorHasOptions = true;
	};
} forEach _conditions;
WL_SectorActionTargetActive = _sectorHasOptions;

private _sectorInfoBox = (ctrlParent WL_CONTROL_MAP) getVariable "BIS_sectorInfoBox";
if (isNull _sector) exitWith {
	BIS_WL_highlightedSector = objNull;
	_sectorInfoBox ctrlShow false;
	_sectorInfoBox ctrlEnable false
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
private _airstrip = "A" in _services;
private _helipad = "H" in _services;
private _harbor = "W" in _services;

private _side = BIS_WL_playerSide;

private _lastScan = (_sector getVariable [format ["BIS_WL_lastScanEnd_%1", _side], -9999]);
private _scanCD = (_lastScan + WL_COOLDOWN_SCAN - serverTime) max 0;

private _getTeamColor = {
	params ["_team"];
	['#004d99', '#7f0400', '#007f04'] # ([west, east, independent] find _team);
};

private _percentage = _sector getVariable ["BIS_WL_captureProgress", 0];
private _revealed = _side in (_sector getVariable ["BIS_WL_revealedBy", []]);
private _captureScoreText = "";
if (!_revealed) then {
	_percentage = 0;
};

private _info = _sector getVariable ["WL_captureDetails", []];
private _myTeamInfo = _info select {
	_x # 0 == BIS_WL_playerSide && _x # 1 > 0
};
if (count _myTeamInfo > 0) then {
	private _teamInfo = _myTeamInfo # 0;

	if (_teamInfo # 1 > 0) then {
		private _sortedInfo = [_info, [], { _x # 1 }, "DESCEND"] call BIS_fnc_sortBy;

		private _scoreTexts = [];
		{
			private _team = _x # 0;
			private _score = _x # 1;
			if (_score > 0) then {
				_scoreTexts pushBack format ["<t color='%1'>%2</t>", [_team] call _getTeamColor, floor _score];
			};
		} forEach _sortedInfo;

		_captureScoreText = _scoreTexts joinString " vs. ";
		_captureScoreText = format ["(%1)", _captureScoreText];
	};
};

private _capturingTeam = _sector getVariable ["BIS_WL_capturingTeam", independent];
private _color = [_capturingTeam] call _getTeamColor;

_sectorInfoBox ctrlSetPosition [(getMousePosition # 0) + safeZoneW / 100, (getMousePosition # 1) + safeZoneH / 50, safeZoneW, safeZoneH];
_sectorInfoBox ctrlCommit 0;

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

private _linebreak = "<br/>";

private _scanCooldownText = [
	localize "STR_A3_WL_param_scan_timeout",
	": <t color='#ff4b4b'>",
	[ceil _scanCD, "MM:SS"] call BIS_fnc_secondsToString,
	"</t>",
	_linebreak
];

private _enemyCaptureText = if (_revealed) then {
	private _previousOwners = _sector getVariable ["BIS_WL_previousOwners", []];
	if (count _previousOwners > 1) then {
		private _fortificationTime = _sector getVariable ["WL_fortificationTime", -1];
		private _fortificationETA = ceil (_fortificationTime - serverTime);
		_fortifactionETA = _fortificationETA max 0;
		format ["<t color='#ff4b4b'>Fortifying %1</t><br/>", [_fortifactionETA, "MM:SS"] call BIS_fnc_secondsToString];
	} else {
		""
	}
} else {
	""
};

private _sectorName = _sector getVariable ["WL2_name", "Sector"];
private _sectorIncome = if !(_sectorName in WL_SPECIAL_SECTORS) then {
	[
		[_side] call WL2_fnc_getMoneySign,
		_sector getVariable "BIS_WL_value",
		"/",
		localize "STR_A3_rscmpprogress_min",
		_linebreak
	] joinString ""
} else {
	""
};

private _sectorInfoText = [
	_sectorName,
	_linebreak,

	_sectorIncome,

	if (count _servicesText > 0) then {
		(_servicesText joinString ", ") + _linebreak
	} else {
		""
	},

	if (_scanCD > 0) then {
		_scanCooldownText joinString ""
	} else {
		""
	},

	if (_percentage > 0 || count _myTeamInfo > 0) then {
		format ["<t color='%1'>%2%3</t> %4<br/>", _color, floor (_percentage * 100), "%", _captureScoreText]
	} else {
		""
	},
	_enemyCaptureText
];

_sectorInfoBox ctrlSetStructuredText parseText format [
	"<t shadow='2' size='%1'>%2</t>",
	1 call WL2_fnc_purchaseMenuGetUIScale,
	_sectorInfoText joinString ""
];

_sectorInfoBox ctrlShow true;
_sectorInfoBox ctrlEnable true;
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