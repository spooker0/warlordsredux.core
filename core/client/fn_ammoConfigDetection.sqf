#include "includes.inc"
params ["_asset"];

private _unitInfo = uiNamespace getVariable ["RscUnitInfo", displayNull];
private _existingControl = _unitInfo displayCtrl 6101;
if (!isNull _existingControl) then {
    ctrlDelete _existingControl;
};

if (cameraOn != _asset) exitWith {
    _asset setVariable ["WL2_currentAmmoConfig", createHashMap];
};

private _turret = cameraOn unitTurret focusOn;
if (count _turret == 0) exitWith {
    _asset setVariable ["WL2_currentAmmoConfig", createHashMap];
};

if (isManualFire cameraOn) then {
    if (_turret isEqualTo [-1]) then {
        _turret = [0];
    } else {
        _turret = [-1];
    };
};

private _currentMagazine = cameraOn currentMagazineTurret _turret;
private _ammo = getText (configFile >> "CfgMagazines" >> _currentMagazine >> "ammo");

private _assetActualType = _asset getVariable ["WL2_orderedClass", typeOf _asset];
private _projectileAmmoOverrides = WL_ASSET(_assetActualType, "ammoOverrides", []);
private _projectileConfig = APS_projectileConfig;

private _currentWeapon = cameraOn currentWeaponTurret _turret;
private _weaponName = getText (configFile >> "CfgWeapons" >> _currentWeapon >> "displayName");

private _selectedAmmoOverrides = _projectileAmmoOverrides select {
    _x # 0 == _ammo
};
if (count _selectedAmmoOverrides > 0) then {
    private _projectileAmmoOverride = _selectedAmmoOverrides # 0;
    private _overrideAmmo = _projectileAmmoOverride # 1;
    _ammo = _overrideAmmo # 0;
    _weaponName = _overrideAmmo # 1;

    private _weaponInfo = _unitInfo displayCtrl 118;

    private _controlGroup = ctrlParentControlsGroup _weaponInfo;
    private _newControl = _unitInfo ctrlCreate ["RscTextRight", 6101, _controlGroup];
    _newControl ctrlSetPosition (ctrlPosition _weaponInfo);
    _newControl ctrlSetBackgroundColor [0.5, 0.5, 0.5, 1];
    _newControl ctrlSetTextColor (ctrlTextColor _weaponInfo);
    _newControl ctrlSetFontHeight (ctrlFontHeight _weaponInfo);
    _newControl ctrlSetShadow 0;
    _newControl ctrlSetText _weaponName;
    _newControl ctrlCommit 0;
};

private _ammoConfig = _projectileConfig getOrDefault [_ammo, createHashMap];
_asset setVariable ["WL2_currentAmmoConfig", _ammoConfig];
_asset setVariable ["WL2_currentWeaponName", _weaponName];