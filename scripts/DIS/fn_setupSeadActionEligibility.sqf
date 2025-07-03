#include "includes.inc"
params ["_asset"];

if (_asset != cameraOn) exitWith {
    false;
};

private _turret = cameraOn unitTurret focusOn;
if (count _turret == 0) exitWith {
    false;
};

private _weaponState = weaponState [cameraOn, _turret];
_weaponState params ["_weapon", "_muzzle", "_firemode", "_magazine", "_ammoCount"];

private _ammo = getText (configFile >> "CfgMagazines" >> _magazine >> "ammo");

private _assetActualType = _asset getVariable ["WL2_orderedClass", typeOf _asset];
private _projectileAmmoOverrides = WL_ASSET(_assetActualType, "ammoOverrides", []);
_projectileAmmoOverrides = _projectileAmmoOverrides select {
    _x # 0 == _ammo
};
if (count _projectileAmmoOverrides > 0) then {
    private _projectileAmmoOverride = _projectileAmmoOverrides # 0;
    private _overrideAmmo = _projectileAmmoOverride # 1;
    _ammo = _overrideAmmo # 0;
};

private _projectileConfig = APS_projectileConfig getOrDefault [_ammo, createHashMap];
_projectileConfig getOrDefault ["sead", false];