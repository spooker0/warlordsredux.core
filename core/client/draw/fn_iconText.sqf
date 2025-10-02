#include "includes.inc"
params ["_asset", "_draw", "_showName", "_mapTextCache"];

if (!_draw) exitWith {""};

private _textFromCache = _mapTextCache getOrDefault [hashValue _asset, []];
if (count _textFromCache == 2) exitWith {
	if (_showName) then {
		format ["%1 (%2)", _textFromCache # 0, _textFromCache # 1];
	} else {
		_textFromCache # 0;
	};
};
if (count _textFromCache == 1) exitWith { _textFromCache # 0 };

private _assetOwnerName = [_asset] call WL2_fnc_getAssetOwnerName;
if (_asset isKindOf "Man") exitWith {
	private _textForCache = if (isPlayer [_asset] && _showName) then {
		_assetOwnerName;
	} else {
		getText (configfile >> "CfgVehicles" >> typeof _asset >> "textSingular");
	};

	_mapTextCache set [hashValue _asset, [_textForCache]];
	_textForCache;
};

if ([_asset] call WL2_fnc_isScannerMunition) exitWith {
	private _originator = getShotParents _asset # 0;

	private _originatorType = if (_originator isKindOf "Man") then {
		"INFANTRY";
	} else {
		toUpper ([_originator] call WL2_fnc_getAssetTypeName);
	};
	private _munitionText = format ["FROM: %1", _originatorType];
	_mapTextCache set [hashValue _asset, [_munitionText, ""]];
	_munitionText;
};

private _vehicleDisplayName = [_asset] call WL2_fnc_getAssetTypeName;
private _ammo = _asset getVariable ["WLM_ammoCargo", 0];
if (_ammo > 0) exitWith {
	private _ammoDisplay = (_ammo call BIS_fnc_numberText) regexReplace [" ", ","];
	private _ammoDisplayText = format ["%1 [%2 kg]", _vehicleDisplayName, _ammoDisplay];

	_mapTextCache set [hashValue _asset, [_ammoDisplayText, _assetOwnerName]];
	_ammoDisplayText;
};

_mapTextCache set [hashValue _asset, [_vehicleDisplayName, _assetOwnerName]];
if (_showName) then {
	format ["%1 (%2)", _vehicleDisplayName, _assetOwnerName];
} else {
	_vehicleDisplayName;
};