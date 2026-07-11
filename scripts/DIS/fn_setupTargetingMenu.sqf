#include "includes.inc"

private _display = uiNamespace getVariable ["RscWLTargetingDisplay", displayNull];
if (isNull _display) then {
	"targetingMenu" cutRsc ["RscWLTargetingDisplay", "PLAIN", -1, true, true];
	_display = uiNamespace getVariable ["RscWLTargetingDisplay", displayNull];
};
private _mainTextControl = _display displayCtrl 6000;
private _incomingTextControl = _display displayCtrl 6001;
private _statusTextControl = _display displayCtrl 6002;
private _weaponTextControl = _display displayCtrl 6003;

uiNamespace setVariable ["DIS_currentTargetingMode", "none"];
uiNamespace setVariable ["WL2_usingVLS", false];

private _assetData = WL_ASSET_DATA;

private _getCurrentMode = {
	if (!alive cameraOn) exitWith {
		["none", "none"]
	};

	if (cameraOn == player && currentMagazine cameraOn == "Laserbatteries") exitWith {
		["lasing", "LASER DESIGNATOR"]
	};

	private _turret = cameraOn unitTurret focusOn;
	if (count _turret == 0) exitWith {
		["none", "none"]
	};

	private _ammoConfig = cameraOn getVariable ["WL2_currentAmmoConfig", createHashMap];
	private _weaponName = cameraOn getVariable ["WL2_currentWeaponName", ""];
	_weaponName = toUpper _weaponName;
	if (_weaponName == "LASER MARKER") exitWith {
		["lasing", _weaponName]
	};
	if (_ammoConfig getOrDefault ["gps", false]) exitWith {
		["gps", _weaponName]
	};
	if (_ammoConfig getOrDefault ["laser", false]) exitWith {
		["laser", _weaponName]
	};
	if (_ammoConfig getOrDefault ["loal", false]) exitWith {
		["loal", _weaponName]
	};
	if (_ammoConfig getOrDefault ["remote", false]) exitWith {
		["remote", _weaponName]
	};
	if (_ammoConfig getOrDefault ["sead", false]) exitWith {
		["sead", _weaponName]
	};

	private _assetActualType = WL_ASSET_TYPE(cameraOn);
	if (WL_ASSET_FIELD(_assetData, _assetActualType, "hasASAM", 0) > 0) exitWith {
		["asam", "Hercules AA"]
	};
	if (WL_ASSET_FIELD(_assetData, _assetActualType, "hasESAM", 0) > 0) exitWith {
		["esam", "RIM-174 AA"]
	};

	if (uiNamespace getVariable ["WL2_usingVLS", false]) exitWith {
		["gps", "LIBERTY-CLASS DESTROYER"]
	};

	["none", "none"];
};

private _targetingControls = [
	["Previous", "gunElevUp"],
	["Next", "gunElevDown"]
];

private _gpsControls = +_targetingControls;
_gpsControls pushBack ["Enter coordinates", "0-9"];

private _hintMap = createHashMapFromArray [
	[
		"asam",
		["AdvancedSam", ["ADVANCED SAM CONTROLS", _targetingControls], false]
	], [
		"esam",
		["ESam", ["ESAM CONTROLS", _targetingControls], false]
	], [
		"laser",
		["Laser", ["LASER CONTROLS", _targetingControls], false]
	], [
		"loal",
		["LOAL", ["LOAL CONTROLS", _targetingControls], false]
	], [
		"gps",
		["GPS", ["GPS CONTROLS", _gpsControls], false]
	], [
		"remote",
		["Remote", ["REMOTE MUNITION CONTROLS", _targetingControls], false]
	], [
		"sead",
		["SEAD", ["SEAD CONTROLS", _targetingControls], false]
	]
];

private _missileTypeData = call DIS_fnc_getMissileType;

private _makeMunitionTextArray = {
	params ["_munitionList"];
	private _munitionTextArray = [];
	{
		private _projectile = _x;
		if (!alive _projectile) then {
			continue;
		};

		private _missileType = _projectile getVariable ["WL2_missileType", ""];

		private _munitionText = if (_missileType == "GPS") then {
			private _terminalTarget = _projectile getVariable ["DIS_terminalTarget", ""];
			if (_terminalTarget == "") then {
				private _target = _projectile getVariable ["DIS_targetCoordinates", [0, 0, 0]];
				private _distance = _projectile distance _target;
				format ["GPS -> AREA [%1KM]", (_distance / 1000) toFixed 1];
			} else {
				format ["GPS -> %1 [TERMINAL]", toUpper _terminalTarget];
			};
		} else {
			private _projectileTarget = _projectile getVariable ["DIS_ultimateTarget", objNull];
			if (!alive _projectileTarget) then {
				format ["%1 -> N/A", _missileType]
			} else {
				private _projectileTargetName = [_projectileTarget] call WL2_fnc_getAssetTypeName;
				private _projectileDistance = _projectile distance _projectileTarget;
				format ["%1 -> %2 [%3KM]", _missileType, toUpper _projectileTargetName, (_projectileDistance / 1000) toFixed 1]
			};
		};

		_munitionTextArray pushBack _munitionText;
	} forEach _munitionList;
	_munitionTextArray;
};

[_mainTextControl, _incomingTextControl, _weaponTextControl] spawn {
	params ["_mainTextControl", "_incomingTextControl", "_weaponTextControl"];
	private _lastSettings = [];
	while { !isNull _mainTextControl } do {
		private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];

		private _allDisplays = uiNamespace getVariable ["IGUI_displays", []];
		private _unitInfo = _allDisplays select { ctrlIDD _x == 300 } select { !isNull (_x displayCtrl 118) };
		private _unitInfoPositionConverted = if (count _unitInfo > 0) then {
			private _weaponInfo = (_unitInfo # 0) displayCtrl 118;
			private _weaponInfoPosition = ctrlPosition _weaponInfo;

			private _weaponInfoParent = ctrlParentControlsGroup _weaponInfo;
			private _weaponInfoParentPosition = ctrlPosition _weaponInfoParent;

			private _unitInfoPosition = [
				_weaponInfoPosition # 0 + _weaponInfoParentPosition # 0,
				_weaponInfoPosition # 1 + _weaponInfoParentPosition # 1,
				_weaponInfoPosition # 2,
				_weaponInfoPosition # 3
			];
			_unitInfoPosition
		} else {
			[0, 0, 0, 0];
		};

		private _targetLeft = _settingsMap getOrDefault ["targetingMenuLeft", 65];
		private _targetTop = _settingsMap getOrDefault ["targetingMenuTop", 30];
		private _fontSize = _settingsMap getOrDefault ["targetingMenuFontSize", 18];
		private _incomingLeft = _settingsMap getOrDefault ["incomingIndicatorLeft", 5];
		private _incomingTop = _settingsMap getOrDefault ["incomingIndicatorTop", 20];

		private _currentSettings = [_targetLeft, _targetTop, _incomingLeft, _incomingTop, _fontSize, _unitInfoPositionConverted];
		if (_lastSettings isEqualTo _currentSettings) then {
			uiSleep 0.5;
			continue;
		};

		_lastSettings = _currentSettings;

		_mainTextControl ctrlSetPosition [
			_targetLeft / 100 * safeZoneW + safeZoneX,
			_targetTop / 100 * safeZoneH + safeZoneY,
			1, 1
		];
		_mainTextControl ctrlSetFontHeight (_fontSize / 18 * 0.032);
		_mainTextControl ctrlCommit 0;

		_incomingTextControl ctrlSetPosition [
			_incomingLeft / 100 * safeZoneW + safeZoneX,
			_incomingTop / 100 * safeZoneH + safeZoneY,
			0.4, 1
		];
		_incomingTextControl ctrlSetFontHeight (_fontSize / 18 * 0.028);
		_incomingTextControl ctrlCommit 0;

		_weaponTextControl ctrlSetPosition _unitInfoPositionConverted;
		_weaponTextControl ctrlCommit 0;
	};
};

private _makeTargetingText = {
	params ["_currentModeTitle", "_targets", "_hasSelections"];
	private _targetArray = [];
	{
		_x params ["_netId", "_targetTextEntry", "_isSelected"];
		if (!_hasSelections) then {
			_targetArray pushBack _targetTextEntry;
			continue;
		};
		if (_isSelected) then {
			_targetArray pushBack format ["|&gt;| %1", _targetTextEntry];
		} else {
			_targetArray pushBack format ["| | %1", _targetTextEntry];
		};
	} forEach _targets;
	format ["%1<br/>%2", _currentModeTitle, _targetArray joinString "<br/>"];
};

private _lastCameraOn = cameraOn;
while { !BIS_WL_missionEnd } do {
	uiSleep 0.05;
	private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];

	private _currentModeData = call _getCurrentMode;
	private _currentMode = _currentModeData # 0;
	private _currentModeTitle = _currentModeData # 1;

	uiNamespace setVariable ["DIS_currentTargetingMode", _currentMode];

	private _text = "";

	if (cameraOn != _lastCameraOn) then {
		_lastCameraOn = cameraOn;
		{
			private _hintEntry = _y;
			_y set [2, false];
		} forEach _hintMap;
	};

	private _hintEntry = _hintMap getOrDefault [_currentMode, []];
	if (count _hintEntry > 0) then {
		private _hintId = _hintEntry # 0;
		private _controlParams = _hintEntry # 1;
		private _shown = _hintEntry # 2;
		if (!_shown) then {
			_hintMap set [_currentMode, [_hintId, _controlParams, true]];
			[_hintId, _controlParams, 10] spawn WL2_fnc_showHint;
		};
	};

	switch(_currentMode) do {
		case "asam";
		case "esam";
		case "loal": {
			private _targetList = [DIS_fnc_getSamTarget, "MANUAL LOCK", "WL2_selectedTargetAA"] call DIS_fnc_getTargetList;
			private _targetText = [_currentModeTitle, _targetList, true] call _makeTargetingText;
			_text = _text + _targetText;
		};
		case "gps": {
			private _nextActionText = (actionKeysNames "gunElevDown") regexReplace ["""", ""];
			_nextActionText = toUpper _nextActionText;
			private _savedCords = cameraOn getVariable ["DIS_savedGPSCoordinates", []];
			private _gpsSelectionIndex = cameraOn getVariable ["DIS_selectionIndex", 0];
			private _gpsCord = cameraOn getVariable ["DIS_gpsCord", ""];
			private _inRangeCalculation = [cameraOn] call DIS_fnc_calculateInRange;

			private _gridText = if (_gpsCord isEqualTo "") then {
				"GRID 000 000";
			} else {
				while { count _gpsCord < 6 } do {
					_gpsCord = "0" + _gpsCord;
				};
				private _easting = _gpsCord select [0, 3];
				private _northing = _gpsCord select [3, 3];
				format ["GRID %1 %2", _easting, _northing];
			};

			_inRangeCalculation params ["_inRange", "_effectiveRange", "_targetDistance"];

			private _color = if (_inRange) then {
				""
			} else {
				" color='#ff0000'"
			};

			private _gpsText = [
				format ["<t size='2'>%1</t>", _gridText],
				"",
				format ["<t%1>TARGET DISTANCE: %2</t>", _color, (_targetDistance / 1000) toFixed 1],
				format ["<t%1>EFFECTIVE RANGE: %2</t>", _color, (_effectiveRange / 1000) toFixed 1]
			];

			if (_inRange) then {
				_gpsText pushBack "<t size='0.8'>READY TO FIRE</t>";
			} else {
				if (_targetDistance < 500) then {
					_gpsText pushBack "<t color='#ff0000' size='0.8'>TOO CLOSE TO TARGET</t>";
				} else {
					_gpsText pushBack "<t color='#ff0000' size='0.8'>ALIGN HEADING AND GET CLOSER / HIGHER / FASTER</t>";
				};
			};

			_gpsText pushBack "";
			_gpsText pushBack "CONTROLS";

			private _allOptions = [
				format ["PRESS [%1] TO ENTER GRID", _nextActionText],
				"ENTER CORDS WITH [0-9] KEYS"
			];
			_allOptions append _savedCords;
			{
				private _option = _x;
				if (_forEachIndex >= 2) then {
					_option = format ["SAVED GRID %1 %2", _option select [0, 3], _option select [3, 3]];
				};
				if (_forEachIndex == _gpsSelectionIndex) then {
					_gpsText pushBack format ["|&gt;| %1", _option];
				} else {
					_gpsText pushBack format ["| | %1", _option];
				};
			} forEach _allOptions;

			_text = _text + format ["%1<br/>%2", _currentModeTitle, _gpsText joinString "<br/>"];
		};
		case "laser": {
			private _targetList = [] call DIS_fnc_getLaserList;
			private _targetText = [_currentModeTitle, _targetList, true] call _makeTargetingText;
			_text = _text + _targetText;
		};
		case "lasing": {
			private _targetList = [] call DIS_fnc_getLaserList;
			private _lasedTargets = _targetList apply { objectFromNetId (_x # 0) };
			_lasedTargets = _lasedTargets select { alive _x };

			private _categories = _lasedTargets apply {
				private _lasedTargetType = WL_ASSET_TYPE(_x);
				WL_ASSET_FIELD(_assetData, _lasedTargetType, "category", "")
			};
			private _lasingText = _currentModeTitle;
			{
				private _category = _x;
				_category = switch (_category) do {
					case "Light Vehicles": {
						"LIGHT";
					};
					case "Heavy Vehicles": {
						"HEAVY";
					};
					case "Naval": {
						"NAVAL";
					};
					case "Rotary Wing";
					case "Fixed Wing": {
						"AIR";
					};
					case "Air Defense": {
						"AA";
					};
					case "Remote Control": {
						"REMOTE";
					};
					case "Gear";
					case "Sector Defense";
					case "Structures": {
						"STATIC";
					};
					default {
						"???"
					};
				};
				_lasingText = format ["%1<br/>%2", _lasingText, _category];
			} forEach _categories;

			_text = _text + _lasingText;
		};
		case "remote": {
			private _targetList = [] call DIS_fnc_getSquadList;
			private _targetText = [_currentModeTitle, _targetList, true] call _makeTargetingText;
			_text = _text + _targetText;
		};
		case "sead": {
			private _targetList = [DIS_fnc_getSeadTarget, "TARGET: AUTO", "WL2_selectedTargetSEAD"] call DIS_fnc_getTargetList;
			private _targetText = [_currentModeTitle, _targetList, true] call _makeTargetingText;
			_text = _text + _targetText;
		};
		default {};
	};

	private _munitionList = cameraOn getVariable ["DIS_munitionList", []];
	private _munitionsTextArray = [_munitionList] call _makeMunitionTextArray;

	if (count _munitionsTextArray > 0) then {
		private _munitionsText = _munitionsTextArray joinString "<br/>";
		_text = format ["%1<br/><br/><br/>%2", _text, _munitionsText];
	};

	_mainTextControl ctrlSetStructuredText parseText format ["<t shadow='2'>%1</t>", _text];

	private _disableIncomingMissileDisplay = _settingsMap getOrDefault ["disableIncomingMissileDisplay", false];
    if (WL_HelmetInterface != 0 && !_disableIncomingMissileDisplay) then {
		private _incomingMissiles = cameraOn getVariable ["WL_incomingMissiles", []];
		_incomingMissiles = _incomingMissiles select { alive _x };

		private _targetVector = velocity cameraOn;
		private _missilesData = _incomingMissiles apply {
			private _missile = _x;
			private _missileState = _missile getVariable ["APS_missileState", "LOCKED"];
			private _distance = _missile distance cameraOn;
			private _relDir = _missile getRelDir cameraOn;
			private _missileApproaching = (_relDir < 90 || _relDir > 270) && !(_missileState == "BLIND");
			private _missileType = _missile getVariable ["WL2_missileNameOverride", _missileTypeData getOrDefault [typeof _missile, "MISSILE"]];

			private _launchParams = _missile getVariable ["DIS_launchParams", [objNull, 1]];
			private _notchResult = [cameraOn, _launchParams # 0, _missile, _launchParams # 1] call DIS_fnc_getNotchResult;

			[_missileState, _distance, _missileApproaching, _missileType, _notchResult];
		};

		_missilesData = [_missilesData, [], {
			if (_x # 2) then {
				_x # 1
			} else {
				_x # 1 + 10000
			};
		}, "ASCEND"] call BIS_fnc_sortBy;

		private _countermeasures = count (("CMflare_Chaff_Ammo" allObjects 2) select {
			(getShotParents _x) # 0 == cameraOn && _x distance cameraOn < 4000;
		});

		private _incomingText = "";
		if (_countermeasures > 0) then {
			_incomingText = _incomingText + format ["CM %1<br/>", _countermeasures];
		};

		{
			_x params ["_missileState", "_distance", "_missileApproaching", "_missileType", "_notchResult"];

			private _color = switch (true) do {
				case (!_missileApproaching): {
					"#000000";
				};
				case (_distance > 5000): {
					"#ffffff";
				};
				case (_distance > 2500): {
					"#ffff00";
				};
				default { "#ff0000" };
			};

			private _distanceText = (_distance / 1000) toFixed 1;
			if (_missileState != "BLIND") then {
				_distanceText = format ["%1 (%2%%)", _distanceText, (round (_notchResult * 25)) min 100];
			};

			_incomingText = format [
				"%1<br/><t color='%2'><t align='left'>%3</t><t align='center'>%4</t><t align='right'>%5</t></t>",
				_incomingText,
				_color,
				_missileType,
				_missileState,
				_distanceText
			];
		} forEach _missilesData;

		_incomingTextControl ctrlSetStructuredText parseText format ["<t shadow='2'>%1</t>", _incomingText];
	} else {
		_incomingTextControl ctrlSetText "";
	};

	private _statusText = "";

	private _reconOptics = cameraOn getVariable ["WL2_hasReconOptics", false];
	if (_reconOptics) then {
		private _isReady = cameraOn getVariable ["WL2_reconOpticsReady", false];
		private _reconText = if (_isReady) then {
			"RECON OPTICS READY<br/>"
		} else {
			"<t color='#000000'>RECON OPTICS WAIT</t><br/>"
		};
		_statusText = _statusText + _reconText;
	};

	private _weaponAmmoCount = cameraOn getVariable ["WL2_deployedWeaponAmmo", -100];
	if (_weaponAmmoCount == 0) then {
		_statusText = _statusText + "<t color='#000000'>INTEGRAL AMMO: 0</t><br/>";
	};
	if (_weaponAmmoCount > 0) then {
		_statusText = _statusText + format ["INTEGRAL AMMO: %1<br/>", _weaponAmmoCount];
	};

	if (currentWeapon cameraOn == "cannon_railgun_fake") then {
		private _mfdValues = getUserMFDValue cameraOn;
		if (count _mfdValues > 0) then {
			private _chargeValue = round ((_mfdValues # 0) * 110);
			if (_chargeValue <= 0) then {
				_chargeValue = 0;
			};
			if (_chargeValue > 30) then {
				private _alreadyReady = uiNamespace getVariable ["WL2_railgunReady", false];
				if (!_alreadyReady) then {
					playSoundUI ["a3\sounds_f\weapons\mines\electron_trigger_1.wss", 1, 0.5];
					uiNamespace setVariable ["WL2_railgunReady", true];
				};
			} else {
				uiNamespace setVariable ["WL2_railgunReady", false];
			};

			if (_chargeValue > 100) then {
				private _alreadyCharged = uiNamespace getVariable ["WL2_railgunCharged", false];
				if (!_alreadyCharged) then {
					playSoundUI ["a3\sounds_f\weapons\mines\electron_trigger_1.wss", 2, 1];
					uiNamespace setVariable ["WL2_railgunCharged", true];
				};
			} else {
				uiNamespace setVariable ["WL2_railgunCharged", false];
			};
			_statusText = _statusText + format ["CHARGING: %1%%<br/>", _chargeValue];
		};
	};

	private _hasECM = cameraOn getVariable ["WL2_hasECMSystem", false];
	if (_hasECM) then {
		private _ecmOn = cameraOn getVariable ["WL2_ecmActive", false];
		private _ecmEffectiveTime = cameraOn getVariable ["WL2_ecmStartEffectTime", 0];
		private _ecmStatusText = if (_ecmOn && fuel cameraOn > 0) then {
			if (serverTime > _ecmEffectiveTime) then {
				private _ecmPercent = (linearConversion [0, 500, speed cameraOn, 0, 1, true]) * 100;
				private _ecmColor = if (_ecmPercent >= 85) then {
					"#00ff00"
				} else {
					"#00ffff"
				};
				format ["<t color='%1'>ECM ACTIVE STRENGTH: %2%%</t><br/>", _ecmColor, round _ecmPercent]
			} else {
				"<t color='#ff0000'>ECM STARTING</t><br/>"
			};
		} else {
			"<t color='#000000'>ECM OFF</t><br/>"
		};
		_statusText = _statusText + _ecmStatusText;
	};

	if (_statusText != "") then {
		_statusTextControl ctrlSetStructuredText parseText format ["<t shadow='2' align='center'>%1</t>", _statusText];
		_statusTextControl ctrlShow true;
	} else {
		_statusTextControl ctrlSetText "";
		_statusTextControl ctrlShow false;
	};

	private _weaponNameOverride = uiNamespace getVariable ["WL2_ammoOverrideName", ""];
	if (_weaponNameOverride != "") then {
		_weaponTextControl ctrlSetText _weaponNameOverride;
		_weaponTextControl ctrlShow true;
	} else {
		_weaponTextControl ctrlSetText "";
		_weaponTextControl ctrlShow false;
	};
};