#include "includes.inc"
params ["_asset", "_draw", "_mapTextCache"];

if (!_draw) exitWith {""};

private _textFromCache = _mapTextCache getOrDefault [hashValue _asset, ""];
if (_textFromCache != "") exitWith {
	_textFromCache;
};

if (vehicle _asset isKindOf "CAManBase") exitWith {
	"";
};

if ([_asset] call WL2_fnc_isScannerMunition) exitWith {
	private _originator = getShotParents _asset # 0;

	private _originatorType = if (_originator isKindOf "Man") then {
		"INFANTRY";
	} else {
		toUpper ([_originator] call WL2_fnc_getAssetTypeName);
	};
	private _munitionText = format ["FROM: %1", _originatorType];
	_mapTextCache set [hashValue _asset, _munitionText];
	_munitionText;
};

private _vehicleDisplayName = [_asset] call WL2_fnc_getAssetTypeName;
private _assetOwnerName = [_asset] call WL2_fnc_getAssetOwnerName;

private _ammo = _asset getVariable ["WLM_ammoCargo", 0];
if (_ammo > 0) exitWith {
	private _ammoDisplay = (_ammo call BIS_fnc_numberText) regexReplace [" ", ","];
	private _ammoDisplayText = format ["%1 [%2 kg]", _vehicleDisplayName, _ammoDisplay];

	_mapTextCache set [hashValue _asset, _ammoDisplayText];
	_ammoDisplayText;
};

private _assetText = format ["%1 %2", _vehicleDisplayName, _assetOwnerName];
_mapTextCache set [hashValue _asset, _assetText];
_assetText;