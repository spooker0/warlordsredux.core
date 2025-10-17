#include "includes.inc"
params ["_asset", "_draw", "_showName", "_mapTextCache"];

if (!_draw) exitWith {""};

private _textFromCache = _mapTextCache getOrDefault [hashValue _asset, []];
if (count _textFromCache == 2) exitWith {
	if (_showName) then {
		private _crewCount = count crew _asset;
		if (!(unitIsUAV _asset) && _crewCount > 0) then {
			format ["%1 (%2, %3)", _textFromCache # 0, _textFromCache # 1, _crewCount];
		} else {
			format ["%1 (%2)", _textFromCache # 0, _textFromCache # 1];
		};
	} else {
		_textFromCache # 0;
	};
};
if (count _textFromCache == 1) exitWith { _textFromCache # 0 };

if (!isNull (_x getVariable ["WL_strongholdSector", objNull])) exitWith {
	private _textForCache = "Stronghold";
	_mapTextCache set [hashValue _asset, [_textForCache]];
	_textForCache;
};

private _assetOwnerName = [_asset] call WL2_fnc_getAssetOwnerName;
if (_asset isKindOf "Man") exitWith {
	private _textForCache = if (isPlayer [_asset] && _showName) then {
		private _nameTag = _asset getVariable ["WL_playerLevel", ""];
		private _showPlayerUids = uiNamespace getVariable ["WL2_showPlayerUids", false];
		if (_showPlayerUids) then {
			format ["%1 [%2] (%3)", _assetOwnerName, _nameTag, getPlayerUID _asset];
		} else {
			format ["%1 [%2]", _assetOwnerName, _nameTag];
		};
	} else {
		getText (configfile >> "CfgVehicles" >> typeof _asset >> "textSingular");
	};

	_mapTextCache set [hashValue _asset, [_textForCache]];
	_textForCache;
};

private _vehicleDisplayName = [_asset] call WL2_fnc_getAssetTypeName;

_mapTextCache set [hashValue _asset, [_vehicleDisplayName, _assetOwnerName]];
if (_showName) then {
	private _crewCount = count crew _asset;
	if (!(unitIsUAV _asset) && _crewCount > 0) then {
		format ["%1 (%2, %3)", _vehicleDisplayName, _assetOwnerName, _crewCount];
	} else {
		format ["%1 (%2)", _vehicleDisplayName, _assetOwnerName];
	};
} else {
	_vehicleDisplayName;
};