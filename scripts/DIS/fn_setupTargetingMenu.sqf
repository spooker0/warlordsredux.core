#include "includes.inc"

private _display = uiNamespace getVariable ["RscWLTargetingMenu", displayNull];
if (isNull _display) then {
	"targetingMenu" cutRsc ["RscWLTargetingMenu", "PLAIN", -1, true, true];
	_display = uiNamespace getVariable ["RscWLTargetingMenu", displayNull];
};
private _texture = _display displayCtrl 5502;
// _texture ctrlWebBrowserAction ["OpenDevConsole"];

uiNamespace setVariable ["DIS_currentTargetingMode", "none"];
uiNamespace setVariable ["WL2_usingVLS", false];

private _assetData = WL_ASSET_DATA;

private _getCurrentMode = {
	if (!alive cameraOn) exitWith {
		["none", "none"]
	};

	private _turret = cameraOn unitTurret focusOn;
	if (count _turret == 0) exitWith {
		["none", "none"]
	};

	private _ammoConfig = cameraOn getVariable ["WL2_currentAmmoConfig", createHashMap];
	private _weaponName = cameraOn getVariable ["WL2_currentWeaponName", ""];
	_weaponName = toUpper _weaponName;
	if (_ammoConfig getOrDefault ["gps", false]) exitWith {
		["gps", _weaponName]
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

	private _assetActualType = cameraOn getVariable ["WL2_orderedClass", typeof cameraOn];
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

[_texture] spawn {
	params ["_texture"];
	private _lastPositionScript = "";
	while { !isNull _texture } do {
		uiSleep 0.5;
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

			[
				(_unitInfoPosition # 0 - safeZoneX) / safeZoneW * 100,
				(_unitInfoPosition # 1 - safeZoneY) / safeZoneH * 100,
				(_unitInfoPosition # 2) / safeZoneW * 100,
				(_unitInfoPosition # 3) / safeZoneH * 100
			];
		} else {
			[0, 0, 0, 0];
		};

		private _targetLeft = _settingsMap getOrDefault ["targetingMenuLeft", 65];
		private _targetTop = _settingsMap getOrDefault ["targetingMenuTop", 30];
		private _fontSize = _settingsMap getOrDefault ["targetingMenuFontSize", 18];
		private _incomingLeft = _settingsMap getOrDefault ["incomingIndicatorLeft", 5];
		private _incomingTop = _settingsMap getOrDefault ["incomingIndicatorTop", 20];
		private _setPositionScript = format ["setSettings(%1, %2, %3, %4, %5, %6);", _targetLeft, _targetTop, _incomingLeft, _incomingTop, _fontSize, _unitInfoPositionConverted];

		if (_setPositionScript == _lastPositionScript) then {
			continue;
		};

		_texture ctrlWebBrowserAction ["ExecJS", _setPositionScript];
		_lastPositionScript = _setPositionScript;
	};
};

private _lastCameraOn = cameraOn;
while { !BIS_WL_missionEnd } do {
	uiSleep 0.05;
	private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];

	private _currentModeData = call _getCurrentMode;
	private _currentMode = _currentModeData # 0;
	private _currentModeTitle = _currentModeData # 1;

	uiNamespace setVariable ["DIS_currentTargetingMode", _currentMode];

	private _script = "";

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

	private _munitionList = cameraOn getVariable ["DIS_munitionList", []];
	private _munitionsTextArray = [_munitionList] call _makeMunitionTextArray;

	if (count _munitionsTextArray > 0) then {
		private _munitionsText = toJSON _munitionsTextArray;
		private _encodedMunitionsText = _texture ctrlWebBrowserAction ["ToBase64", _munitionsText];

		private _munitionScript = format ["setMunitionList(atobr(""%1""));", _encodedMunitionsText];
		_script = _script + _munitionScript;
	} else {
		_script = _script + "setMunitionList('[]');";
	};

	switch(_currentMode) do {
		case "asam";
		case "esam";
		case "loal": {
			private _targetList = [DIS_fnc_getSamTarget, "MANUAL LOCK", "WL2_selectedTargetAA"] call DIS_fnc_getTargetList;
			private _targetsText = toJSON _targetList;
			_targetsText = _texture ctrlWebBrowserAction ["ToBase64", _targetsText];
			_script = _script + format ["setMode(""aa"", ""%1"");setAATargetData(atobr(""%2""));", _currentModeTitle, _targetsText];
		};
		case "gps": {
			private _nextActionText = (actionKeysNames "gunElevDown") regexReplace ["""", ""];
			_nextActionText = toUpper _nextActionText;
			private _savedCords = cameraOn getVariable ["DIS_savedGPSCoordinates", []];
			private _gpsSelectionIndex = cameraOn getVariable ["DIS_selectionIndex", 0];
			private _gpsCord = cameraOn getVariable ["DIS_gpsCord", ""];
			private _inRangeCalculation = [cameraOn] call DIS_fnc_calculateInRange;

			_script = _script + format [
				"setMode(""gps"", ""%1"");setGPSData(""%2"", %3, %4, ""%5"", ""%6"", ""%7"", %8);",
				_currentModeTitle,
				_nextActionText,
				_savedCords,
				_gpsSelectionIndex,
				_gpsCord,
				(_inRangeCalculation # 2 / 1000) toFixed 1,
				(_inRangeCalculation # 1 / 1000) toFixed 1,
				_inRangeCalculation # 0
			];
		};
		case "remote": {
			private _targetList = [] call DIS_fnc_getSquadList;
			private _targetsText = toJSON _targetList;
			_targetsText = _texture ctrlWebBrowserAction ["ToBase64", _targetsText];
			_script = _script + format ["setMode(""remote"", ""%1"");setRemoteTargetData(atobr(""%2""));", _currentModeTitle, _targetsText];
		};
		case "sead": {
			private _targetList = [DIS_fnc_getSeadTarget, "TARGET: AUTO", "WL2_selectedTargetSEAD"] call DIS_fnc_getTargetList;
			private _targetsText = toJSON _targetList;
			_targetsText = _texture ctrlWebBrowserAction ["ToBase64", _targetsText];
			_script = _script + format ["setMode(""sead"", ""%1"");setSEADTargetData(atobr(""%2""));", _currentModeTitle, _targetsText];
		};
		default {
			_script = _script + format ["setMode(""none"", ""%1"");", _currentModeTitle];
		};
	};

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

			[_missileState, _distance, _missileApproaching, _missileType];
		};

		private _encodedMissilesText = _texture ctrlWebBrowserAction ["ToBase64", toJSON _missilesData];
		_script = _script + format ["setIncomingMissiles(atobr(""%1""));", _encodedMissilesText];
    } else {
		_script = _script + "setIncomingMissiles('[]');";
	};

	private _reconOptics = cameraOn getVariable ["WL2_hasReconOptics", false];
	if (_reconOptics) then {
		private _isReady = cameraOn getVariable ["WL2_reconOpticsReady", false];
		_script = _script + format ["setReconOptics(true, %1);", _isReady];
	} else {
		_script = _script + "setReconOptics(false, false);";
	};

	private _ecmCharges = cameraOn getVariable ["WL2_ecmCharges", -100];
	if (_ecmCharges != -100) then {
		private _nextChargeTime = cameraOn getVariable ["WL2_ecmNextChargeTime", 0];
		_script = _script + format ["setEcmCharges(true, %1, %2);", _ecmCharges, _nextChargeTime];
	} else {
		_script = _script + "setEcmCharges(false, 0, 0);";
	};

	private _weaponNameOverride = uiNamespace getVariable ["WL2_ammoOverrideName", ""];
	_script = _script + format ["setWeaponName(""%1"");", _weaponNameOverride];

	_texture ctrlWebBrowserAction ["ExecJS", _script];
};