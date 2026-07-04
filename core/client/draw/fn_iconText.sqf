#include "includes.inc"
params ["_asset", "_mapTextCache", "_showDetailed"];

if (!isNull (_asset getVariable ["WL_strongholdSector", objNull])) exitWith { "Stronghold" };

_asset = vehicle _asset;

if (_asset isKindOf "Man") exitWith {
	if (isPlayer [_asset]) then {
		if (side group _asset == BIS_WL_playerSide) then {
			private _nameTag = _asset getVariable ["WL_playerLevel", ""];
			private _showPlayerUids = uiNamespace getVariable ["WL2_showPlayerUids", false];
			private _assetOwnerName = [_asset] call WL2_fnc_getAssetOwnerName;
			if (_showPlayerUids) then {
				format ["%1 [%2] (%3)", _assetOwnerName, _nameTag, getPlayerUID _asset];
			} else {
				format ["%1 [%2]", _assetOwnerName, _nameTag];
			};
		} else {
			"player";
		};
	} else {
		private _textFromCache = _mapTextCache getOrDefault [typeOf _asset, ""];
		if (_textFromCache != "") then {
			_textFromCache
		} else {
			private _textForCache = getText (configfile >> "CfgVehicles" >> typeof _asset >> "textSingular");
			_mapTextCache set [typeOf _asset, _textForCache];
			_textForCache;
		};
	};
};

if (!_showDetailed) exitWith {
	[_asset] call WL2_fnc_getAssetTypeShortName;
};

private _vehicleDisplayName = [_asset] call WL2_fnc_getAssetTypeName;
private _vehicleSide = [_asset] call WL2_fnc_getAssetSide;
if (_vehicleSide == BIS_WL_playerSide) then {
	private _crewCount = count crew _asset;
	private _assetOwnerName = [_asset] call WL2_fnc_getAssetOwnerName;

	if (!(unitIsUAV _asset) && _crewCount > 0) then {
		format ["%1 (%2, %3)", _vehicleDisplayName, _assetOwnerName, _crewCount];
	} else {
		format ["%1 (%2)", _vehicleDisplayName, _assetOwnerName];
	};
} else {
	_vehicleDisplayName;
};