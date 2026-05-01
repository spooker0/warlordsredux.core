#include "includes.inc"
params ["_asset", "_isAircraft"];

private _eligibleFreeRearm = true;
if (_isAircraft) then {
    private _currentPylonInfo = getAllPylonsInfo _asset;
    {
        private _pylonName = _x # 3;
        if (_pylonName != "") then {
            private _maxAmmo = getNumber (configFile >> "CfgMagazines" >> _pylonName >> "count");
            private _currentAmmo = _x # 4;

            if (_maxAmmo > _currentAmmo) then {
                _eligibleFreeRearm = false;
            };
        };
    } forEach _currentPylonInfo;

    {
        private _currentAmmo = _x # 2;
        private _magName = _x # 0;
        private _magMaxAmmo = getNumber (configFile >> "CfgMagazines" >> _magName >> "count");
        if (_magMaxAmmo > _currentAmmo) then {
            _eligibleFreeRearm = false;
        };
    } forEach (magazinesAllTurrets _asset);
} else {
    private _defaultMags = _asset getVariable ["WLM_savedDefaultMags", []];
    private _currentMags = magazinesAllTurrets _asset;
    _defaultMags sort true;
    _currentMags sort true;

    {
        if (_forEachIndex >= count _defaultMags) exitWith {
            _eligibleFreeRearm = false;
        };
        private _defaultMag = _defaultMags # _forEachIndex;
        private _currentMag = _x;

        if (_defaultMag # 0 != _currentMag # 0) then {
            _eligibleFreeRearm = false;
        };
        if (_defaultMag # 2 != _currentMag # 2) then {
            _eligibleFreeRearm = false;
        };
    } forEach _currentMags;

    if (_asset call APS_fnc_getMaxAmmo > _asset getVariable ["apsAmmo", 0]) then {
        _eligibleFreeRearm = false;
    };

    if (_asset getVariable ["WLM_ineligibleForRearmTimer", 0] > serverTime) then {
        _eligibleFreeRearm = false;
    };

    // Check if the vehicle is totally empty of magazines
    // Do not use someAmmo, which only checks main muzzle
    private _empty = count (_currentMags select {
        _x # 2 > 0
    }) == 0;
    if (_empty) then {
        _eligibleFreeRearm = false;
    };

    private _assetActualType = WL_ASSET_TYPE(_asset);

    private _mineClear = _asset getVariable ["WL2_mineClearCharges", -1];
    if (_mineClear != -1) then {
        private _mineClearConfig = WL_ASSET(_assetActualType, "mineClear", -1);
        if (_mineClearConfig > _mineClear) then {
            _eligibleFreeRearm = false;
        };
    };

    private _installable = _asset getVariable ["WL2_installable", ""];
    if (_installable == "") then {
        private _installableConfig = WL_ASSET(_assetActualType, "loaded", "");
        if (_installableConfig != "") then {
            _eligibleFreeRearm = false;
        };
    };
};

_eligibleFreeRearm;