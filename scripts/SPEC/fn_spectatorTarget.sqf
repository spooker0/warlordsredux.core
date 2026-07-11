#include "includes.inc"
private _assetData = WL_ASSET_DATA;

private _isProjectileVisible = {
    params ["_projectile", "_cameraPos", "_maxDistance"];
    if (!alive _projectile) exitWith { false; };
    if (_projectile distance _cameraPos > _maxDistance) exitWith { false; };
    if (_projectile isKindOf "MissileCore") exitWith { true; };
    if (_projectile isKindOf "RocketCore") exitWith { true; };
    if (_projectile isKindOf "BombCore") exitWith { true; };
    if (_projectile isKindOf "ShellCore") exitWith { true; };
    if (_projectile isKindOf "SubmunitionCore") exitWith { true; };
    false;
};

while { WL_IsSpectator } do {
    private _hmdSettingProfiles = profileNamespace getVariable ["WL2_HMDSettingProfiles", []];
    private _currentProfileIndex = uiNamespace getVariable ["WL2_HMDSettingProfileIndex", 0];
    private _settingProfileData = if (_currentProfileIndex < count _hmdSettingProfiles) then {
        _hmdSettingProfiles # _currentProfileIndex;
    } else {
        createHashMap;
    };

    private _isHoldingAlt = uiNamespace getVariable ["WL2_isHoldingAlt", false];

    private _cameraPos = positionCameraToWorld [0, 0, 0];

    private _laserTargets = entities "LaserTarget";
    private _laserViewDistance = _settingProfileData getOrDefault ["LASER", 5000];
    _laserTargets = _laserTargets select {
        alive _x &&
        _x distance _cameraPos <= _laserViewDistance &&
        !(isNull (_x getVariable ["WL_laserPlayer", objNull]));
    };
    _laserTargets = _laserTargets apply {
        private _responsiblePlayer = _x getVariable ["WL_laserPlayer", objNull];
        private _playerName = name _responsiblePlayer;
        if (_playerName == "Error: No vehicle") then {
            _playerName = "";
        };
        [_x, _playerName];
    };

    private _allVehicles = (vehicles + allUnits) select {
        WL_ISUP(_x) &&
        simulationEnabled _x &&
        !(_x isKindOf "LaserTarget");
    };

    private _infantryViewDistance = _settingProfileData getOrDefault ["INFANTRY", 500];
    private _infantryNameViewDistance = _settingProfileData getOrDefault ["INFANTRY NAME", 250];
    private _vehicleViewDistance = _settingProfileData getOrDefault ["VEHICLE", 5000];
    private _aircraftViewDistance = _settingProfileData getOrDefault ["AIRCRAFT", 10000];
    private _airDefenseViewDistance = _settingProfileData getOrDefault ["AIR DEFENSE", 5000];

    private _vehicles = [];
    private _infantry = [];
    {
        private _target = _x;

        private _targetSide = [_target] call WL2_fnc_getAssetSide;
        if !(_targetSide in [west, east, independent]) then {
            continue;
        };

        private _targetColor = switch (_targetSide) do {
            case west: {
                [0, 0.3, 0.6, 1]
            };
            case east: {
                [0.5, 0, 0, 1]
            };
            case independent: {
                [0, 0.5, 0, 1]
            };
            default {
                [1, 1, 1, 1]
            };
        };

        private _distance = _cameraPos distance _target;
        if (_target isKindOf "Man") then {
            if (typeof _target in ["B_UAV_AI", "O_UAV_AI", "I_UAV_AI"]) then {
                continue;
            };
            private _assetName = if (_distance < _infantryNameViewDistance) then {
                [_target, true] call BIS_fnc_getName;
            } else {
                ""
            };
            if (_distance > _infantryViewDistance) then {
                continue;
            };
            _infantry pushBack [
                _target,
                _targetColor,
                _assetName
            ];
        } else {
            private _assetTypeName = toUpper ([_target] call WL2_fnc_getAssetTypeShortName);
            private _assetName = if (!_isHoldingAlt) then {
                _assetTypeName
            } else {
                private _ownerPlayer = (_target getVariable ["BIS_WL_ownerAsset", "123"]) call BIS_fnc_getUnitByUID;
                private _ownerName = if (isNull _ownerPlayer) then {
                    [_target] call WL2_fnc_getAssetSide;
                } else {
                    [_ownerPlayer, true] call BIS_fnc_getName
                };
                format ["%1 (%2, %3%%)", _assetTypeName, _ownerName, round ((1 - (damage _target)) * 100)]
            };
            _assetName = format ["%1 %2", _assetName, (_distance / 1000) toFixed 1];

            private _assetActualType = WL_ASSET_TYPE(_target);
            private _assetCategory = WL_ASSET_FIELD(_assetData, _assetActualType, "category", "Other");

            if (_assetCategory == "Air Defense") then {
                if (_target distance _cameraPos > _airDefenseViewDistance) then {
                    continue;
                };
            } else {
                if (_target isKindOf "Air") then {
                    if (_target distance _cameraPos > _aircraftViewDistance) then {
                        continue;
                    };
                } else {
                    if (_target distance _cameraPos > _vehicleViewDistance) then {
                        continue;
                    };
                };
            };

            private _targetIcon = "\A3\ui_f\data\IGUI\RscCustomInfo\Sensors\Targets\UnknownGround_ca.paa";
            private _targetIconInfo = getTextureInfo _targetIcon;
            private _targetIconRatio = _targetIconInfo # 0 / _targetIconInfo # 1;

            private _iconSize = linearConversion [0, 2000, _distance, 0.9, 0.5, true];
            private _iconTextSize = linearConversion [0, 5000, _distance, 0.035, 0.030];

            _vehicles pushBack [
                _target,
                _targetIcon,
                _targetColor,
                _iconSize,
                _targetIconRatio,
                _assetName,
                _iconTextSize
            ];
        };
    } forEach _allVehicles;

    private _missileViewDistance = _settingProfileData getOrDefault ["MISSILE", 5000];
    private _projectiles = (8 allObjects 2) select {
        [_x, _cameraPos, _missileViewDistance] call _isProjectileVisible;
    };

    private _sectors = [];
    private _sectorsToShow = if (_isHoldingAlt) then {
        BIS_WL_allSectors
    } else {
        []
    };
    {
        private _sector = _x;
        private _sectorArea = _sector getVariable "objectAreaComplete";
        private _sectorName = _sector getVariable ["WL2_name", "Sector"];
        private _captureProgress = _sector getVariable ["BIS_WL_captureProgress", 0];
        if (_captureProgress > 0) then {
            _sectorName = format ["%1 [%2%%]", _sectorName, round (_captureProgress * 100)]
        };

        private _sectorOwner = _sector getVariable ["BIS_WL_owner", sideUnknown];
        private _sectorColor = switch (_sectorOwner) do {
            case west: {
                [0, 0.3, 0.6, 0.8]
            };
            case east: {
                [0.5, 0, 0, 0.8]
            };
            case independent: {
                [0, 0.5, 0, 0.8]
            };
        };
        private _sectorIcon = switch (_sectorOwner) do {
            case west: {
                "\A3\ui_f\data\map\markers\nato\b_installation.paa";
            };
            case east: {
                "\A3\ui_f\data\map\markers\nato\o_installation.paa";
            };
            case independent: {
                "\A3\ui_f\data\map\markers\nato\n_installation.paa";
            };
        };

        _sectors pushBack [
            _sector,
            _sectorIcon,
            _sectorColor,
            _sectorName
        ];
    } forEach _sectorsToShow;

    uiNamespace setVariable ["WL2_spectatorDrawLasers", _laserTargets];
    uiNamespace setVariable ["WL2_spectatorDrawProjectiles", _projectiles];
    uiNamespace setVariable ["WL2_spectatorDrawInfantry", _infantry];
    uiNamespace setVariable ["WL2_spectatorDrawVehicles", _vehicles];
    uiNamespace setVariable ["WL2_spectatorDrawSectors", _sectors];

    uiSleep 0.1;
};