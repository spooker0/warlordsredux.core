#include "includes.inc"
params ["_asset"];

private _defaultMags = _asset getVariable ["WLM_savedDefaultMags", []];
{
    _x params ["_className", "_turretPath", "_ammoCount", "_id", "_creator"];
    _asset removeMagazinesTurret [_className, _turretPath];
} forEach _defaultMags;

// Remove all weapons
private _allTurrets = [[-1]] + allTurrets _asset;
private _weaponsByTurret = createHashMap;
{
    private _turretPath = _x;
    private _weaponsForTurret = _asset weaponsTurret _turretPath;
    _weaponsByTurret set [_turretPath, _weaponsForTurret];
    {
        private _weapon = _x;
        _asset removeWeaponTurret [_weapon, _turretPath];
    } forEach _weaponsForTurret;
} forEach _allTurrets;

{
    _x params ["_className", "_turretPath", "_ammoCount", "_id", "_creator"];
    _asset addMagazineTurret [_className, _turretPath, _ammoCount];
} forEach _defaultMags;

// Re-add all weapons after magazines
{
    private _turretPath = _x;
    private _weapons = _y;
    {
        private _weapon = _x;
        _asset addWeaponTurret [_weapon, _turretPath];
    } forEach _weapons;
} forEach _weaponsByTurret;

_asset spawn APS_fnc_rearmAPS;
_asset setVariable ['WL2_smokeCurtains', 2];

if (_asset getVariable ["WL2_mortarShellCountHE", -1] != -1) then {
    _asset setVariable ["WL2_mortarShellCountHE", 8, true];
};

private _assetActualType = _asset getVariable ["WL2_orderedClass", typeOf _asset];

if (_asset getVariable ["WL2_smartMinesAT", -1] != -1) then {
    _asset setVariable ["WL2_smartMinesAT", WL_ASSET(_assetActualType, "smartMineAT", 0), true];
};

if (_asset getVariable ["WL2_smartMinesAP", -1] != -1) then {
    _asset setVariable ["WL2_smartMinesAP", WL_ASSET(_assetActualType, "smartMineAP", 0), true];
};

private _loadedItem = WL_ASSET(_assetActualType, "loaded", "");
if (_loadedItem != "") then {
    _asset setVariable ["WL2_deployCrates", 1, true];
};