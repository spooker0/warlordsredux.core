#include "includes.inc"
params ["_asset"];

private _assetActualType = _asset getVariable ["WL2_orderedClass", typeOf _asset];
private _projectileAmmoOverrides = WL_ASSET(_assetActualType, "ammoOverrides", []);
private _projectileConfig = APS_projectileConfig;

private _seadReady = {
	if (cameraOn != _asset) exitWith {
		false;
	};

	private _turret = cameraOn unitTurret focusOn;
	if (count _turret == 0) exitWith {
		false;
	};

	private _weaponState = weaponState [cameraOn, _turret];
	_weaponState params ["_weapon", "_muzzle", "_firemode", "_magazine", "_ammoCount"];
	private _ammo = getText (configFile >> "CfgMagazines" >> _magazine >> "ammo");

	private _selectedAmmoOverrides = _projectileAmmoOverrides select {
		_x # 0 == _ammo
	};
	if (count _selectedAmmoOverrides > 0) then {
		private _projectileAmmoOverride = _selectedAmmoOverrides # 0;
		private _overrideAmmo = _projectileAmmoOverride # 1;
		_ammo = _overrideAmmo # 0;
	};
	private _ammoConfig = _projectileConfig getOrDefault [_ammo, createHashMap];
	_ammoConfig getOrDefault ["sead", false];
};

private _previousEligible = false;
while { alive _asset } do {
	sleep 0.5;
	private _eligible = call _seadReady;
	if (_eligible == _previousEligible) then {
		continue;
	};

	if (_eligible) then {
		private _display = uiNamespace getVariable ["RscWLSeadTargetingMenu", displayNull];
		if (isNull _display) then {
			"seadtarget" cutRsc ["RscWLSeadTargetingMenu", "PLAIN", -1, true, true];
			_display = uiNamespace getVariable "RscWLSeadTargetingMenu";
		};
		private _texture = _display displayCtrl 5502;
		// _texture ctrlWebBrowserAction ["OpenDevConsole"];

		_texture ctrlAddEventHandler ["PageLoaded", {
			params ["_texture"];
			[_texture] spawn {
				params ["_texture"];
				while { !isNull _texture } do {
					private _targetList = [DIS_fnc_getSeadTarget, "TARGET: AUTO"] call DIS_fnc_getTargetList;
					[_texture, _targetList] call DIS_fnc_sendTargetData;
					sleep 1;
				};
			};
		}];
	} else {
		"seadtarget" cutText ["", "PLAIN"];
	};

	_previousEligible = _eligible;
};
"seadtarget" cutText ["", "PLAIN"];