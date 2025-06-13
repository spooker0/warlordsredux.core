#include "includes.inc"

private _display = uiNamespace getVariable ["RscWarlordsHUD", displayNull];
if (isNull _display) then {
	"Warlords" cutRsc ["RscWarlordsHUD", "PLAIN"];
	_display = uiNamespace getVariable ["RscWarlordsHUD", displayNull];
};

private _timer = _display displayCtrl 2100;
private _moneyControl = _display displayCtrl 2101;
private _subordinateControl = _display displayCtrl 2102;
private _squadControl = _display displayCtrl 2103;

private _rearmControl = _display displayCtrl 2104;
private _repairControl = _display displayCtrl 2105;

private _captureProgressBar = _display displayCtrl 2106;
private _captureText = _display displayCtrl 2107;

private _gameStart = missionNamespace getVariable ["gameStart", 0];

private _getTeamColorHex = {
	params ["_team"];
	['#004d99', '#7f0400', '#007f04'] # ([west, east, independent] find _team);
};

private _getTeamColorRGB = {
	params ["_team"];
	[[0.0, 0.3, 0.6, 1], [0.5, 0.0, 0.0, 1], [0.0, 0.5, 0.0, 1]] # ([west, east, independent] find _team);
};

private _lastMoney = 0;

while { !BIS_WL_missionEnd } do {
	sleep 1;

	private _side = BIS_WL_playerSide;

	_timer ctrlSetStructuredText parseText format [
		"<t shadow='2' size ='1'><img color='#ffffff' image='a3\ui_f\data\igui\cfg\actions\settimer_ca.paa'></img>  %1</t>",
		[36000 - (serverTime - _gameStart), "HH:MM:SS"] call BIS_fnc_secondsToString
	];

	private _currentMoney = (missionNamespace getVariable "fundsDatabaseClients") get (getPlayerUID player);
	if (_currentMoney != _lastMoney) then {
		_lastMoney = _currentMoney;
		call WL2_fnc_purchaseMenuRefresh;
	};

	_moneyControl ctrlSetStructuredText parseText format [
		"<t shadow='2' size ='1.1' align='middle'>%1%2</t>    <t shadow='2' size ='0.8' align='middle'>+%3</t>",
		[_side] call WL2_fnc_getMoneySign,
		(missionNamespace getVariable "fundsDatabaseClients") get (getPlayerUID player),
		missionNamespace getVariable [format ["WL2_actualIncome_%1", _side], 0]
	];

	_subordinateControl ctrlSetStructuredText parseText format [
		"<t shadow='2' size ='1.1'>AI: %1/%2</t>",
		BIS_WL_matesAvailable,
		missionNamespace getVariable [format ["BIS_WL_maxSubordinates_%1", _side], 1]
	];

	_squadControl ctrlSetStructuredText parseText format [
		"<t shadow='2' size ='1.1'>SQD: %1</t>",
		count (["getAllInSquad"] call SQD_fnc_client)
	];

	private _rearmText = if (cameraOn isKindOf "Man") then {
		"";
	} else {
		private _cooldown = ((cameraOn getVariable ["BIS_WL_nextRearm", 0]) - serverTime) max 0;
		if (_cooldown > 0) then {
			format ["<t color='#ff0000' shadow='2'>REARM: %1</t>", [_cooldown, "MM:SS"] call BIS_fnc_secondsToString];
		} else {
			format ["<t color='#00ff00' shadow='2'>REARM: READY</t>"];
		};
	};
	_rearmControl ctrlSetStructuredText parseText _rearmText;

	private _repairText = if (cameraOn isKindOf "Man") then {
		"";
	} else {
		private _cooldown = ((cameraOn getVariable ["WL2_nextRepair", 0]) - serverTime) max 0;
		if (_cooldown > 0) then {
			format ["<t color='#ff0000' shadow='2'>REPAIR: %1</t>", [_cooldown, "MM:SS"] call BIS_fnc_secondsToString];
		} else {
			format ["<t color='#00ff00' shadow='2'>REPAIR: READY</t>"];
		};
	};
	_repairControl ctrlSetStructuredText parseText _repairText;

	private _visitedSectorId = BIS_WL_allSectors findIf { player inArea (_x getVariable "objectAreaComplete") };
	if (_visitedSectorId == -1) then {
		_captureText ctrlShow false;
		_captureProgressBar ctrlShow false;
		continue;
	};

	private _sector = BIS_WL_allSectors # _visitedSectorId;
	private _sectorName = _sector getVariable ["WL2_name", "Unknown"];

	private _captureProgress = _sector getVariable ["BIS_WL_captureProgress", 0];
	private _sectorOwner = _sector getVariable ["BIS_WL_owner", independent];

	private _captureDetails = _sector getVariable ["WL_captureDetails", []];

	private _sectorOwnerCap = 0;
	private _capturingTeamCap = 0;
	private _capturingTeam = independent;
	if (count _captureDetails > 0) then {
		_captureDetails = [_captureDetails, [], { _x # 1 }, "DESCEND"] call BIS_fnc_sortBy;

		_capturingTeam = _captureDetails select {
			_x # 0 != _sectorOwner
		} select 0 select 0;

		_sectorOwnerCap = _captureDetails select {
			_x # 0 == _sectorOwner
		} select 0 select 1;
		_capturingTeamCap = _captureDetails select {
			_x # 0 == _capturingTeam
		} select 0 select 1;
	};

	_captureText ctrlShow true;
	if (_sectorOwner == _side) then {
		if (_captureProgress == 0) then {
			_captureProgressBar ctrlShow false;
			_captureText ctrlSetStructuredText parseText format [
				"<t shadow='2' size ='1' align='center'>%1</t>",
				toUpper _sectorName
			];
		} else {
			_captureProgressBar ctrlShow true;
			_captureProgressBar progressSetPosition _captureProgress;
			_captureProgressBar ctrlSetTextColor ([_capturingTeam] call _getTeamColorRGB);

			_captureText ctrlSetStructuredText parseText format [
				"<t shadow='2' size='1'><t align='left' color='%1'>%2</t><t align='center'>DEFENDING %3</t><t align='right' color='%4'>%5</t></t>",
				[_sectorOwner] call _getTeamColorHex,
				floor _sectorOwnerCap,
				toUpper _sectorName,
				[_capturingTeam] call _getTeamColorHex,
				floor _capturingTeamCap
			];
		};
	} else {
		if (_sector in (BIS_WL_sectorsArray # 3)) then {
			_captureProgressBar ctrlShow true;
			_captureProgressBar progressSetPosition _captureProgress;
			_captureProgressBar ctrlSetTextColor ([_capturingTeam] call _getTeamColorRGB);

			_captureText ctrlSetStructuredText parseText format [
				"<t shadow='2' size='1'><t align='left' color='%1'>%2</t><t align='center'>ATTACKING %3</t><t align='right' color='%4'>%5</t></t>",
				[_sectorOwner] call _getTeamColorHex,
				floor _sectorOwnerCap,
				toUpper _sectorName,
				[_capturingTeam] call _getTeamColorHex,
				floor _capturingTeamCap
			];
		} else {
			_captureProgressBar ctrlShow false;
			_captureProgressBar progressSetPosition _captureProgress;
			_captureText ctrlSetStructuredText parseText format [
				"<t shadow='2' size ='1' align='center'>RESTRICTED: %1</t>",
				toUpper _sectorName
			];
		};
	};
};