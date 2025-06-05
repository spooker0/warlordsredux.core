#include "includes.inc"
params ["_asset"];

private _actionText = format ["<t color='#00ffcc'>GPS Munition Configuration (%1)</t>", actionKeysNames ["binocular", 1, "Combo"]];
private _actionID = _asset addAction [
	_actionText,
	DIS_fnc_setupGPSMenu,
	[],
	100,
	true,
	false,
	"binocular",
	"vehicle _this == _target",
	50,
	false
];

private _assetActualType = _asset getVariable ["WL2_orderedClass", typeOf _asset];
private _assetAmmoOverrides = WL_ASSET(_assetActualType, "ammoOverrides", []);
private _projectileConfigMap = APS_projectileConfig;

while { alive _asset } do {
	sleep 2;
	if (!local _asset) then {
		continue;
	};
	if (vehicle player != _asset) then {
		continue;
	};
	private _currentMagazine = currentMagazine _asset;
	private _currentAmmo = getText (configFile >> "CfgMagazines" >> _currentMagazine >> "ammo");
	private _currentAmmoActual = _assetAmmoOverrides select {
		_x # 0 == _currentAmmo
	};
	if (count _currentAmmoActual == 0) then {
		continue;
	};
	_currentAmmoActual = _currentAmmoActual # 0;

	private _projectileConfig = _projectileConfigMap getOrDefault [_currentAmmoActual # 1 # 0, createHashMap];
	if (_projectileConfig getOrDefault ["gps", false]) then {
		private _inRangeCalculation = [_asset] call DIS_fnc_calculateInRange;
		uiNamespace setVariable ["WL2_gpsTargetingLastUpdate", serverTime];
		uiNamespace setVariable ["WL2_gpsTargetingInfo", _inRangeCalculation];
		if (_inRangeCalculation # 0) then {
			playSoundUI ["a3\ui_f_curator\data\sound\cfgsound\ping04.wss", 1, 2];
		} else {
			playSoundUI ["AddItemOk", 1, 0.5, true];
		};
	};
};