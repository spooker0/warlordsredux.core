#include "includes.inc"
if (isDedicated) exitWith {};

uiNamespace setVariable ["WL_HelmetInterfaceLaserIcons", []];
// uiNamespace setVariable ["WL_HelmetInterfaceFlareIcons", []];
uiNamespace setVariable ["WL_HelmetInterfaceSAMIcons", []];
uiNamespace setVariable ["WL_HelmetInterfaceTargetVehicleIcons", []];
uiNamespace setVariable ["WL_HelmetInterfaceTargetInfantryIcons", []];

uiNamespace setVariable ["WL2_gpsTargetingLastUpdate", 0];

addMissionEventHandler ["Draw3D", {
    if (WL_HelmetInterface == 0) exitWith {};

    private _laserIcons = uiNamespace getVariable ["WL_HelmetInterfaceLaserIcons", []];
    {
        drawIcon3D _x;
    } forEach _laserIcons;

    // private _flareIcons = uiNamespace getVariable ["WL_HelmetInterfaceFlareIcons", []];
    // {
    //     drawIcon3D _x;
    // } forEach _flareIcons;

    private _samIcons = uiNamespace getVariable ["WL_HelmetInterfaceSAMIcons", []];
    {
        private _icon = +_x;
        private _location = (_x # 2) modelToWorldVisual [0, 0, 0];
        _icon set [2, _location];
        drawIcon3D _icon;
    } forEach _samIcons;

    private _targetVehicleIcons = uiNamespace getVariable ["WL_HelmetInterfaceTargetVehicleIcons", []];
    {
        private _target = _x # 2;
        private _icon = +_x;
        private _centerOfMass = getCenterOfMass _target;
        _centerOfMass set [2, _centerOfMass # 2 + 3];
        _icon set [2, _target modelToWorldVisual _centerOfMass];
        drawIcon3D _icon;
    } forEach _targetVehicleIcons;

    private _targetInfantryIcons = uiNamespace getVariable ["WL_HelmetInterfaceTargetInfantryIcons", []];
    {
        private _targetPos = _x # 2;
        private _screenPos = worldToScreen _targetPos;
        private _isInViewRadius = count _screenPos == 2 && {
            (_screenPos distance2D [0.5, 0.5]) < 0.4
        };
        private _displayName = if (_isInViewRadius) then {
            _x # 6;
        } else {
            ""
        };
        drawIcon3D [
            _x # 0,
            _x # 1,
            _x # 2,
            _x # 3,
            _x # 4,
            _x # 5,
            _displayName,
            _x # 7,
            _x # 8,
            _x # 9
        ];
    } forEach _targetInfantryIcons;

    private _vehicle = cameraOn;
    if (!alive _vehicle) exitWith {};

    private _incomingMissiles = _vehicle getVariable ["WL_incomingMissiles", []];
    _incomingMissiles = _incomingMissiles select {
        alive _x;
    };
    {
        private _missile = _x;
        private _missilePos = _missile modelToWorldVisual [0, 0, 0];
        private _distance = _vehicle distance _missile;

        private _relDir = _missile getRelDir _vehicle;
        private _missileApproaching = _relDir < 90 || _relDir > 270;
        private _missileUpdateInitialized = _missile getVariable ["WL_missileUpdateInitialized", false];
        if (!_missileUpdateInitialized) then {
            _missile setVariable ["WL_missileUpdateInitialized", true];
            private _launcher = _missile getVariable ["WL_launcher", objNull];
            [_missile] remoteExec ["APS_fnc_projectileStateUpdate", _launcher];
        };
        _missile setVariable ["WL_missileApproaching", _missileApproaching];

        private _missileState = _missile getVariable ["APS_missileState", "LOCKED"];
        private _color = switch true do {
            case (_missileState == "BOOST"): {
                [0, 0, 1, 1]
            };
            case (!_missileApproaching || _missileState == "BLIND"): {
                [0, 0, 0, 1]
            };
            case (_distance > 5000): {
                [1, 1, 1, 1]
            };
            case (_distance > 2500): {
                [1, 1, 0, 1]
            };
            default {
                [1, 0, 0, 1]
            };
        };

        private _missileStateText = if (_missileState == "") then {
            ""
        } else {
            format [" [%1]", _missileState]
        };

        drawIcon3D [
            "\A3\ui_f\data\IGUI\RscCustomInfo\Sensors\Targets\missile_ca.paa",
            _color,
            _missilePos,
            0.8,
            0.8,
            0,
            format ["%1 KM%2", (round (_distance / 100)) / 10, _missileStateText],
            true,
            0.035,
            "RobotoCondensedBold",
            "center",
            true
        ];
    } forEach _incomingMissiles;

    private _approachingMissiles = _incomingMissiles select {
        alive _x && _x getVariable ["WL_missileApproaching", false]
    };
    private _lastKnownLauncher = _vehicle getVariable ["WL_incomingLauncherLastKnown", objNull];
    if (count _approachingMissiles > 0 && alive _lastKnownLauncher) then {
        private _lastKnownLauncherPos = _lastKnownLauncher modelToWorldVisual [0, 0, 0];
        private _targetSide = [_lastKnownLauncher] call WL2_fnc_getAssetSide;

        private _opacity = if (serverTime % 0.2 > 0.1) then {
            1
        } else {
            0
        };
        private _targetColor = switch (_targetSide) do {
            case west: {
                [0, 0.3, 0.6, _opacity]
            };
            case east: {
                [0.5, 0, 0, _opacity]
            };
            case independent: {
                [0, 0.5, 0, _opacity]
            };
        };

        drawIcon3D [
            "\A3\ui_f\data\IGUI\RscCustomInfo\Sensors\Targets\ActiveSensor_ca.paa",
            _targetColor,
            _lastKnownLauncherPos,
            1.5,
            1.5,
            0,
            "LAUNCH DETECTED",
            true,
            0.035,
            "RobotoCondensedBold",
            "center",
            true
        ];
    };
}];

0 spawn {
    private _assetData = WL_ASSET_DATA;
    private _missileTypeData = call DIS_fnc_getMissileType;
    private _apsProjectileConfig = APS_projectileConfig;
    private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];

    while { !BIS_WL_missionEnd } do {
        if (WL_HelmetInterface == 2) then {
            uiSleep 0.1;
        } else {
            uiSleep 1;
        };

        if (WL_HelmetInterface == 0) then {
            continue;
        };

        private _vehicle = cameraOn;
        if (!alive _vehicle) then {
            uiSleep 1;
            continue;
        };

        private _hmdSettingProfiles = profileNamespace getVariable ["WL2_HMDSettingProfiles", []];
        private _currentProfileIndex = uiNamespace getVariable ["WL2_HMDSettingProfileIndex", 0];
        private _settingProfileData = if (_currentProfileIndex < count _hmdSettingProfiles) then {
            _hmdSettingProfiles # _currentProfileIndex;
        } else {
            createHashMap;
        };

        private _side = BIS_WL_playerSide;
        private _laserTargets = entities "LaserTarget";
        private _laserIcons = [];
        private _laserViewDistance = _settingProfileData getOrDefault ["LASER", 5000];
        {
            private _target = _x;
            if (_target distance _vehicle > _laserViewDistance) then {
                continue;
            };

            private _responsiblePlayer = _target getVariable ["WL_laserPlayer", objNull];
            if (isNull _responsiblePlayer) then {
                continue;
            };
            private _playerName = name _responsiblePlayer;
            if (_playerName == "Error: No vehicle") then {
                continue;
            };
            if ([_responsiblePlayer] call WL2_fnc_getAssetSide != _side) then {
                continue;
            };
            _laserIcons pushBack [
                "\A3\ui_f\data\IGUI\RscCustomInfo\Sensors\Targets\LaserTarget_ca.paa",
                [1, 0, 0, 1],
                _target modelToWorldVisual [0, 0, 0],
                1,
                1,
                45,
                _playerName,
                0,
                0.05,
                "RobotoCondensedBold"
            ];
        } forEach _laserTargets;
        uiNamespace setVariable ["WL_HelmetInterfaceLaserIcons", _laserIcons];

        // private _flares = (8 allObjects 2) select {
        //     typeof _x == "CMflare_Chaff_Ammo"
        // };
        // private _flareIcons = [];
        // {
        //     private _flare = _x;
        //     private _flarePos = _flare modelToWorldVisual [0, 0, 0];
        //     private _distance = _vehicle distance _flare;

        //     if (_distance > 4000) then {
        //         continue;
        //     };

        //     _flareIcons pushBack [
        //         "\A3\ui_f\data\IGUI\RscCustomInfo\Sensors\Targets\missileAlt_ca.paa",
        //         [1, 1, 1, 1],
        //         _flare modelToWorldVisual [0, 0, 0],
        //         0.8,
        //         0.8,
        //         0
        //     ];
        // } forEach _flares;
        // uiNamespace setVariable ["WL_HelmetInterfaceFlareIcons", _flareIcons];

        private _vehicleActualType = _vehicle getVariable ["WL2_orderedClass", typeOf _vehicle];
        private _vehicleCategory = WL_ASSET_FIELD(_assetData, _vehicleActualType, "category", "Other");
        private _hasThreatDetector = WL_ASSET_FIELD(_assetData, _vehicleActualType, "threatDetection", 0);
        private _samIcons = [];
        private _missileViewDistance = _settingProfileData getOrDefault ["MISSILE", 5000];
        if (_vehicleCategory == "AirDefense" || _hasThreatDetector > 0) then {
            private _samMissiles = (8 allObjects 2) select {
                if !(_x isKindOf "MissileCore") then {
                    false;
                } else {
                    private _projectile = _x;
                    private _projectileConfig = _apsProjectileConfig getOrDefault [typeOf _projectile, createHashMap];
                    private _projectileSAM = _projectileConfig getOrDefault ["sam", false];
                    _projectileSAM && _projectile distance _vehicle < _missileViewDistance;
                };
            };

            {
                private _missileType = _x getVariable ["WL2_missileNameOverride", _missileTypeData getOrDefault [typeof _x, "MISSILE"]];
                _samIcons pushBack [
                    "\A3\ui_f\data\IGUI\RscCustomInfo\Sensors\Targets\missileAlt_ca.paa",
                    [1, 0, 0, 1],
                    _x,
                    0.8,
                    0.8,
                    0,
                    _missileType,
                    true,
                    0.035,
                    "RobotoCondensedBold",
                    "center",
                    true
                ];
            } forEach _samMissiles;

            private _targetLock = playerTargetLock;
            if (!isNull (_targetLock # 0)) then {
                private _notchResult = [_targetLock # 0, _vehicle] call DIS_fnc_getNotchResult;
                private _targetLockPercent = round ((_notchResult * 100) max 0 min 95);

                _samIcons pushBack [
                    "\A3\ui_f\data\IGUI\Cfg\Cursors\lock_target_ca.paa",
                    if (_targetLockPercent > 75) then {
                        [0, 1, 0, 1]
                    } else {
                        [1, 0, 0, 1]
                    },
                    _targetLock # 0,
                    0.8,
                    0.8,
                    0,
                    format ["TRACK %1%%", _targetLockPercent],
                    true,
                    0.035,
                    "RobotoCondensedBold",
                    "center",
                    true,
                    0,
                    0.02
                ];
            };
        };
        uiNamespace setVariable ["WL_HelmetInterfaceSAMIcons", _samIcons];

        private _targets = [];

        {
            _targets pushBackUnique (_x # 0);
        } forEach (getSensorTargets _vehicle);

        {
            if (_x # 1 > -10) then {
                _targets pushBackUnique (_x # 0);
            };
        } forEach (listRemoteTargets _side);

        private _scannerUnits = vehicles select {
            alive _x &&
            _x getVariable ["WL_scannerOn", false]
        };
        {
            private _scannedObjects = _x getVariable ["WL_scannedObjects", []];
            {
                _targets pushBackUnique _x;
            } forEach _scannedObjects;
        } forEach _scannerUnits;

        if (cameraOn isKindOf "Air") then {
            private _staticAAWest = cameraOn nearEntities ["B_static_AA_F", 2500];
            private _staticAAEast = cameraOn nearEntities ["O_static_AA_F", 2500];
            {
                if (alive _x) then {
                    _targets pushBackUnique _x;
                };
            } forEach (_staticAAWest + _staticAAEast);
        };

        _targets = _targets select {
            alive _x &&
            lifeState _x != "INCAPACITATED" &&
            (_x getVariable ["WL_spawnedAsset", false] || isPlayer _x) &&
            _x != _vehicle;
        };

        private _targetInfantryIcons = [];
        private _targetVehicleIcons = [];

        private _incomingMissiles = _vehicle getVariable ["WL_incomingMissiles", []];
        private _approachingMissiles = _incomingMissiles select {
            alive _x && _x getVariable ["WL_missileApproaching", false]
        };

        private _infantryViewDistance = _settingProfileData getOrDefault ["INFANTRY", 500];
        private _infantryNameViewDistance = _settingProfileData getOrDefault ["INFANTRY NAME", 250];
        private _vehicleViewDistance = _settingProfileData getOrDefault ["VEHICLE", 5000];
        private _aircraftViewDistance = _settingProfileData getOrDefault ["AIRCRAFT", 10000];
        if (_aircraftViewDistance == 20000) then {
            _aircraftViewDistance = 100000;
        };
        private _airDefenseViewDistance = _settingProfileData getOrDefault ["AIR DEFENSE", 5000];

        private _hasApproachingMissiles = count _approachingMissiles > 0;
        {
            private _target = _x;

            private _lastKnownLauncher = _vehicle getVariable ["WL_incomingLauncherLastKnown", objNull];
            if (WL_HelmetInterface == 2 && _hasApproachingMissiles && _lastKnownLauncher == _target) then {
                continue;
            };

            private _targetSide = [_target] call WL2_fnc_getAssetSide;
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
                    [1, 1, 1, 0]
                };
            };

            if (_target isKindOf "Man") then {
                if (_vehicleCategory == "AirDefense") then {
                    continue;
                };
                if (_target distance _vehicle > _infantryViewDistance) then {
                    continue;
                };

                private _centerOfMass = _target selectionPosition "spine2";
                _centerOfMass set [2, _centerOfMass # 2 + 1];

                private _assetName = if (_target distance _vehicle < _infantryNameViewDistance) then {
                    if (isPlayer _target) then {
                        name _target;
                    } else {
                        getText (configfile >> "CfgVehicles" >> typeof _target >> "textSingular");
                    };
                } else {
                    "";
                };

                _targetInfantryIcons pushBack [
                    "\A3\ui_f\data\IGUI\RscCustomInfo\Sensors\Targets\UnknownGround_ca.paa",
                    _targetColor,
                    _target modelToWorldVisual _centerOfMass,
                    0.3,
                    0.3,
                    45,
                    _assetName,
                    true,
                    0.025,
                    "RobotoCondensedBold"
                ];
            } else {
                private _assetTypeName = [_target] call WL2_fnc_getAssetTypeName;

                private _assetName = if (_targetSide == _side) then {
                    private _ownerName = [_target] call WL2_fnc_getAssetOwnerName;
                    format ["%1 (%2)", _assetTypeName, _ownerName];
                } else {
                    _assetTypeName;
                };

                private _altitude = getPosATL _target # 2;
                if (_altitude > 1000) then {
                    _assetName = format ["%1 - ALT %2", _assetName, (_altitude / 1000) toFixed 1];
                };

                private _assetActualType = _target getVariable ["WL2_orderedClass", typeof _target];
                private _assetCategory = WL_ASSET_FIELD(_assetData, _assetActualType, "category", "Other");

                private _targetIcon = "";
                private _targetIconSize = 0.8;
                if (_assetCategory == "AirDefense") then {
                    _targetIcon = "\A3\ui_f\data\map\markers\nato\b_antiair.paa";
                    _targetIconSize = 0.6;
                    if (_target distance _vehicle > _airDefenseViewDistance) then {
                        continue;
                    };
                } else {
                    _targetIcon = "\A3\ui_f\data\IGUI\Cfg\Cursors\lock_target_ca.paa";
                    if (_target isKindOf "Air") then {
                        if (_target distance _vehicle > _aircraftViewDistance) then {
                            continue;
                        };
                    } else {
                        if (_target distance _vehicle > _vehicleViewDistance) then {
                            continue;
                        };
                    };
                };

                private _vehicleColor = +_targetColor;
                _vehicleColor set [3, 0.8];

                _targetVehicleIcons pushBack [
                    _targetIcon,
                    _vehicleColor,
                    _target,    // convert to position later
                    _targetIconSize,
                    _targetIconSize,
                    0,
                    _assetName,
                    true,
                    0.025,
                    "RobotoCondensedBold",
                    "center",
                    true,
                    0,
                    -0.04
                ];
            };
        } forEach _targets;

        private _advancedThreat = _vehicle getVariable ["WL2_advancedThreat", objNull];
        if (alive _advancedThreat) then {
            _targetVehicleIcons pushBack [
                "\A3\ui_f\data\IGUI\RscCustomInfo\Sensors\Threats\locking_ca.paa",
                [1, 1, 0, 1],
                _advancedThreat,
                1.0,
                1.0,
                0,
                "THREAT",
                true,
                0.035,
                "RobotoCondensedBold",
                "center",
                true
            ];
        };

        {
            private _selectedTarget = _vehicle getVariable [format ["WL2_selectedTarget%1", _x], objNull];
            if (alive _selectedTarget) then {
                private _isInAngle = if (unitIsUAV _vehicle) then {
                    true;
                } else {
                    [getPosATL _vehicle, getDir _vehicle, 120, getPosATL _selectedTarget] call WL2_fnc_inAngleCheck;
                };

                private _angleColor = if (_isInAngle || _x == "AA") then {
                    [1, 0, 0, 1]
                } else {
                    [0, 0, 0, 1]
                };

                _targetVehicleIcons pushBack [
                    "\A3\ui_f\data\IGUI\RscCustomInfo\Sensors\Threats\locking_ca.paa",
                    _angleColor,
                    _selectedTarget,
                    1.0,
                    1.0,
                    0,
                    format ["LOCK %1", _x],
                    true,
                    0.035,
                    "RobotoCondensedBold",
                    "center",
                    true
                ];
            };
        } forEach ["AA", "SEAD"];

        uiNamespace setVariable ["WL_HelmetInterfaceTargetInfantryIcons", _targetInfantryIcons];
        uiNamespace setVariable ["WL_HelmetInterfaceTargetVehicleIcons", _targetVehicleIcons];

        private _incomingMissiles = _vehicle getVariable ["WL_incomingMissiles", []];
        private _warningPlayed = player getVariable ["WL_missileWarningPlayed", -100];
        private _lockedMissiles = _incomingMissiles select {
            alive _x && _x getVariable ["WL_missileApproaching", true];
        };
        private _threatVolume = _settingsMap getOrDefault ["rwr5", 1];
        if (count _lockedMissiles > 0 && serverTime - _warningPlayed > 1.5 && _threatVolume > 0) then {
            private _lastMissile = _lockedMissiles # (count _lockedMissiles - 1);
            private _relDir = _vehicle getRelDir _lastMissile;
            private _angleReadout = switch (true) do {
                case (_relDir < 45 || _relDir > 315): {
                    0
                };
                case (_relDir < 135): {
                    90
                };
                case (_relDir < 225): {
                    180
                };
                default {
                    270
                };
            };

            private _soundFile = format ["incMissile_%1", _angleReadout];
            playSoundUI [_soundFile, 5 * _threatVolume];

            player setVariable ["WL_missileWarningPlayed", serverTime];
        };
    };
};

0 spawn {
    while { !BIS_WL_missionEnd && !WL_IsSpectator } do {
        uiSleep 1;

		private _isAfk = player getVariable ["WL2_afk", false];
        if (_isAfk) then {
            WL_HelmetInterface = 0;
            continue;
        };

        private _override = player getVariable ["WL_hmdOverride", -1];
        if (_override > 0) then {
            WL_HelmetInterface = _override;
            continue;
        };

        private _vehicle = cameraOn;

        private _vehicleActualType = _vehicle getVariable ["WL2_orderedClass", typeOf _vehicle];
        private _inWhitelistedVehicle = WL_ASSET(_vehicleActualType, "hasHMD", 0) > 0;

        if (_inWhitelistedVehicle) then {
            WL_HelmetInterface = 2;
        } else {
            WL_HelmetInterface = 0;
        };
    };
};