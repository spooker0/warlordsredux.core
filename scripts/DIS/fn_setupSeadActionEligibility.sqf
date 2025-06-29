#include "includes.inc"
params ["_target", "_caller"];

if (_target != cameraOn) exitWith {
    false;
};
if (_caller != focusOn) exitWith {
    false;
};

private _turret = cameraOn unitTurret focusOn;
if (count _turret == 0) exitWith {
    false;
};

private _weaponState = weaponState [cameraOn, _turret];
_weaponState params ["_weapon", "_muzzle", "_firemode", "_magazine", "_ammoCount"];

private _ammo = getText (configFile >> "CfgMagazines" >> _magazine >> "ammo");

private _assetActualType = _target getVariable ["WL2_orderedClass", typeOf _target];
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