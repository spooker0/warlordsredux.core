private _vehicle = cameraOn;

waitUntil {
	sleep 0.1;
	_vehicle = cameraOn;
	!(alive player) || _vehicle isKindOf "Air"
};

if !(alive player) exitWith {};

private _soundEffects = if (side group player == west) then {
	["pullUp", "altWarning", "bingoFuel"]
} else {
	["pullUpRita", "altRita", "fuelRita"]
};

_vehicle setVariable ["WL2_rwr1Played", 0];
_vehicle setVariable ["WL2_rwr2Played", 0];
_vehicle setVariable ["WL2_rwr3Played", 0];

private _landingGearUpTime = getNumber (configFile >> "CfgVehicles" >> typeOf _vehicle >> "gearUpTime");
private _hasLandingGear = _landingGearUpTime > 0;

_vehicle setVariable ["WL2_landingGear", _hasLandingGear];
_vehicle addEventHandler ["Gear", {
	params ["_vehicle", "_gearState"];
	_vehicle setVariable ["WL2_landingGear", _gearState];
}];

_vehicle addEventHandler ["Killed", {
	params ["_unit", "_killer", "_instigator", "_useEffects"];
	_unit removeAllEventHandlers "Gear";
	_unit removeAllEventHandlers "IncomingMissile";
	_unit removeAllEventHandlers "Killed";
}];

private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];
while { _vehicle isKindOf "Air" && alive player && alive _vehicle && vehicle player == _vehicle } do {
	private _landingGear = _vehicle getVariable ["WL2_landingGear", false];
	private _altitude = getPosATL _vehicle # 2;

	if (_vehicle getVariable ["WL2_rwr1Played", 0] < serverTime - 2) then {
		private _pullUpVolume = _settingsMap getOrDefault ["rwr1", 0.3];
		if (_altitude <= 2000 && _altitude > 100 && !_landingGear) then {
			if (asin (vectorDir _vehicle # 2) < -((_altitude * 40) / speed _vehicle)) then {
				playSoundUI [_soundEffects # 0, _pullUpVolume];
				_vehicle setVariable ["WL2_rwr1Played", serverTime];
			};
		};
	};

	if (_vehicle isKindOf "Plane" && _vehicle getVariable ["WL2_rwr2Played", 0] < serverTime - 1.7) then {
		private _altitudeVolume = _settingsMap getOrDefault ["rwr2", 0.3];
		if (_altitude < 100 && !_landingGear) then {
			playSoundUI [_soundEffects # 1, _altitudeVolume];
			_vehicle setVariable ["WL2_rwr2Played", serverTime];
		};
	};

	if (_vehicle getVariable ["WL2_rwr3Played", 0] < serverTime - 2) then {
		private _fuelVolume = _settingsMap getOrDefault ["rwr3", 0.3];
		if (fuel _vehicle < 0.2) then {
			playSoundUI [_soundEffects # 2, _fuelVolume];
			_vehicle setVariable ["WL2_rwr3Played", serverTime];
		};
	};

	private _newSensorTargets = getSensorTargets _vehicle;
	private _oldSensorTargets = _vehicle getVariable ["WL2_storedTargets", []];
	if !(_newSensorTargets isEqualTo _oldSensorTargets) then {
		private _targetChangeVolume = _settingsMap getOrDefault ["rwr4", 0.3];
		if (count _newSensorTargets > count _oldSensorTargets) then {
			playSoundUI ["radarTargetNew", _targetChangeVolume];
		};
		if (count _newSensorTargets < count _oldSensorTargets) then {
			playSoundUI ["radarTargetLost", _targetChangeVolume];
		};
		_vehicle setVariable ["WL2_storedTargets", _newSensorTargets];
	};

	sleep 1;
};