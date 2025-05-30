#include "..\..\warlords_constants.inc"

if (isDedicated) exitWith {};

uiNamespace setVariable ["WL_HelmetInterfaceLaserIcons", []];
// uiNamespace setVariable ["WL_HelmetInterfaceFlareIcons", []];
uiNamespace setVariable ["WL_HelmetInterfaceSAMIcons", []];
uiNamespace setVariable ["WL_HelmetInterfaceMunitionIcons", []];
uiNamespace setVariable ["WL_HelmetInterfaceTargetVehicleIcons", []];
uiNamespace setVariable ["WL_HelmetInterfaceTargetInfantryIcons", []];
uiNamespace setVariable ["WL_HelmetInterfaceMaxDistance", 5000];

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

    private _munitionIcons = uiNamespace getVariable ["WL_HelmetInterfaceMunitionIcons", []];
    {
        drawIcon3D _x;
    } forEach _munitionIcons;

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

    private _gpsTargetingLastUpdate = uiNamespace getVariable ["WL2_gpsTargetingLastUpdate", 0];
    private _gpsTargetingInfo = uiNamespace getVariable ["WL2_gpsTargetingInfo", []];
    if (_gpsTargetingLastUpdate + 2.5 > serverTime && count _gpsTargetingInfo > 0) then {
        private _inRange = _gpsTargetingInfo # 0;
        private _range = _gpsTargetingInfo # 1;
        private _distanceNeeded = _gpsTargetingInfo # 2;
        private _targetPosATL = _gpsTargetingInfo # 3;

        private _color = if (_inRange) then {
            [0, 1, 0, 1]
        } else {
            [1, 0, 0, 1]
        };

        drawIcon3D [
            "\A3\ui_f\data\IGUI\RscIngameUI\RscOptics\square.paa",
            _color,
            _targetPosATL,
            0.3,
            0.3,
            0,
            format ["TGT %1", (_distanceNeeded / 1000) toFixed 1],
            0,
            0.03,
            "TahomaB",
            "right",
            false,
            0.005,
            -0.02
        ];
        drawIcon3D [
            "",
            _color,
            _targetPosATL,
            0.3,
            0.3,
            0,
            format ["RNG %1", (_range / 1000) toFixed 1],
            0,
            0.03,
            "TahomaB",
            "right",
            false,
            0.005,
            -0.005
        ];
    };
}];

0 spawn {
    private _categoryMap = missionNamespace getVariable ["WL2_categories", createHashMap];
    private _missileTypeData = createHashMapFromArray [
        ["M_Zephyr", "ZEPHYR"],
        ["M_Titan_AA_long", "TITAN"],
        ["ammo_Missile_mim145", "DEFENDER"],
        ["ammo_Missile_s750", "RHEA"],
        ["ammo_Missile_rim116", "SPARTAN"],
        ["ammo_Missile_rim162", "CENTURION"],
        ["M_70mm_SAAMI", "SAAMI"]
    ];
    private _apsProjectileConfig = APS_projectileConfig;
    private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];

    while { !BIS_WL_missionEnd } do {
        if (WL_HelmetInterface == 2) then {
            sleep 0.1;
        } else {
            sleep 1;
        };

        if (WL_HelmetInterface == 0) then {
            continue;
        };

        private _vehicle = cameraOn;
        if (!alive _vehicle) then {
            sleep 1;
            continue;
        };

        private _side = BIS_WL_playerSide;
        private _laserTargets = entities "LaserTarget";
        private _laserIcons = [];
        {
            private _target = _x;
            if (_target distance _vehicle > 7000) then {
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
        private _vehicleCategory = _categoryMap getOrDefault [_vehicleActualType, "Other"];
        private _samIcons = [];
        if (_vehicleCategory == "AirDefense") then {
            private _samMissiles = (8 allObjects 2) select {
                if !(_x isKindOf "MissileCore") then {
                    false;
                } else {
                    private _projectile = _x;
                    private _projectileConfig = _apsProjectileConfig getOrDefault [typeOf _projectile, createHashMap];
                    private _projectileSAM = _projectileConfig getOrDefault ["sam", false];
                    _projectileSAM && _projectile distance _vehicle < 8000;
                };
            };

            {
                _samIcons pushBack [
                    "\A3\ui_f\data\IGUI\RscCustomInfo\Sensors\Targets\missileAlt_ca.paa",
                    [1, 0, 0, 1],
                    _x,
                    0.8,
                    0.8,
                    0,
                    _missileTypeData getOrDefault [typeof _x, "MISSILE"],
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
            isEngineOn _x &&
            _x getVariable ["WL_scannerOn", false]
        };
        {
            private _scannedObjects = _x getVariable ["WL_scannedObjects", []];
            {
                _targets pushBackUnique _x;
            } forEach _scannedObjects;
        } forEach _scannerUnits;

        private _maxDistance = switch (WL_HelmetInterface) do {
            case 0: { 0 };
            case 1: { 5000 };
            case 2: { 5000 };
            default { 5000 };
        };
        private _maxThreshold = uiNamespace getVariable ["WL_HelmetInterfaceMaxDistance", 5000];
        _maxDistance = _maxDistance min _maxThreshold;

        private _munitions = _targets select {
            _vehicle distance _x < _maxDistance &&
            [_x] call WL2_fnc_isScannerMunition;
        };
        private _munitionIcons = [];
        {
            private _munition = _x;
            private _munitionPos = _munition modelToWorldVisual [0, 0, 0];

            private _originator = getShotParents _munition # 0;
            private _originatorType = if (_originator isKindOf "Man") then {
                "INFANTRY";
            } else {
                toUpper ([_originator] call WL2_fnc_getAssetTypeName);
            };

            private _color = switch ([_originator] call WL2_fnc_getAssetSide) do {
                case west: { [0, 0.3, 0.6, 0.9] };
                case east: { [0.5, 0, 0, 0.9] };
                case independent: { [0, 0.6, 0, 0.9] };
                default { [1, 1, 1, 1] };
            };

            _munitionIcons pushBack [
                "\A3\ui_f\data\IGUI\RscCustomInfo\Sensors\Targets\missileAlt_ca.paa",
                _color,
                _munitionPos,
                0.8,
                0.8,
                0,
                format ["FROM: %1", _originatorType],
                true,
                0.035,
                "RobotoCondensedBold",
                "center",
                true
            ];
        } forEach _munitions;
        uiNamespace setVariable ["WL_HelmetInterfaceMunitionIcons", _munitionIcons];

        _targets = _targets select {
            alive _x &&
            lifeState _x != "INCAPACITATED" &&
            (_x getVariable ["WL_spawnedAsset", false] || isPlayer _x) &&
            _x distance _vehicle < _maxDistance &&
            _x != _vehicle;
        };

        private _targetInfantryIcons = [];
        private _targetVehicleIcons = [];

        private _incomingMissiles = _vehicle getVariable ["WL_incomingMissiles", []];
        private _approachingMissiles = _incomingMissiles select {
            alive _x && _x getVariable ["WL_missileApproaching", false]
        };
        private _hasApproachingMissiles = count _approachingMissiles > 0;
        {
            private _target = _x;
            private _targetIsInfantry = _target isKindOf "Man";

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
                    if ([_x] call WL2_fnc_isScannerMunition) then {
                        [1, 1, 1, 1]
                    } else {
                        [1, 1, 1, 0]
                    };
                };
            };

            private _assetTypeName = [_target] call WL2_fnc_getAssetTypeName;

            private _assetName = if (_targetSide == _side) then {
                private _ownerPlayer = (_target getVariable ["BIS_WL_ownerAsset", "123"]) call BIS_fnc_getUnitByUID;
                private _ownerName = if (name _ownerPlayer == "Error: No vehicle") then {
                    "";
                } else {
                    format [" (%1)", name _ownerPlayer];
                };
                format ["%1%2", _assetTypeName, _ownerName];
            } else {
                _assetTypeName;
            };

            if (_targetIsInfantry) then {
                private _centerOfMass = _target selectionPosition "spine2";
                _centerOfMass set [2, _centerOfMass # 2 + 1];

                _targetInfantryIcons pushBack [
                    "\A3\ui_f\data\IGUI\RscCustomInfo\Sensors\Targets\UnknownGround_ca.paa",
                    _targetColor,
                    _target modelToWorldVisual _centerOfMass,
                    0.5,
                    0.5,
                    45,
                    _assetName,
                    true,
                    0.03,
                    "RobotoCondensedBold"
                ];
            } else {
                private _assetActualType = _target getVariable ["WL2_orderedClass", typeof _target];
                private _assetCategory = _categoryMap getOrDefault [_assetActualType, "Other"];

                private _targetIcon = "";
                private _targetIconSize = 1;
                if (_assetCategory == "AirDefense") then {
                    _targetIcon = "\A3\ui_f\data\map\markers\nato\b_antiair.paa";
                    _targetIconSize = 0.8;
                } else {
                    _targetIcon = "\A3\ui_f\data\IGUI\Cfg\Cursors\lock_target_ca.paa";
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
                    0.032,
                    "RobotoCondensedBold",
                    "center",
                    true,
                    0,
                    -0.05
                ];
            };
        } forEach _targets;
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
        sleep 1;

        private _override = player getVariable ["WL_hmdOverride", -1];
        if (_override > 0) then {
            WL_HelmetInterface = _override;
            continue;
        };

        // private _vehicle = vehicle (getConnectedUAVUnit player);
        // if (isNull _vehicle) then {
        //     _vehicle = vehicle player;
        // };
        private _vehicle = cameraOn;

        private _allowedVehicles = missionNamespace getVariable ["WL2_hasHMD", createHashMap];
        private _vehicleActualType = _vehicle getVariable ["WL2_orderedClass", typeOf _vehicle];
        private _inWhitelistedVehicle = _allowedVehicles getOrDefault [_vehicleActualType, false];

        private _sideVehiclesVars = format ["BIS_WL_%1OwnedVehicles", BIS_WL_playerSide];
        private _sideVehicles = missionNamespace getVariable [_sideVehiclesVars, []];
        private _hasAWACSMap = missionNamespace getVariable ["WL2_hasAWACS", createHashMap];

        private _friendlyNetwork = _sideVehicles select {
            private _distance = _vehicle distance _x;
            private _activated = _x getVariable ["WL_ewNetActive", false] && isEngineOn _x;
            private _inJamRange = _distance < _x getVariable ["WL_ewNetRange", 0];

            private _scannerRange = _x getVariable ["WL_scanRadius", 0];
            private _isScanner = _scannerRange > 100;
            private _inScanRange = _distance < _scannerRange;
            (_inJamRange && _activated) || (_isScanner && _inScanRange);
        };
        private _inNetworkRange = count _friendlyNetwork > 0;
        private _hasGlasses = goggles player == "G_Tactical_Clear";

        if (_hasGlasses || _inWhitelistedVehicle) then {
            private _gogglesDisplay = uiNamespace getVariable ["RscWLGogglesDisplay", displayNull];
            if (isNull _gogglesDisplay) then {
                "WLGoggles" cutRsc ["RscWLGogglesDisplay", "PLAIN"];
            };
            player setVariable ["WL_hasHelmetDisplay", true];
        } else {
            "WLGoggles" cutText ["", "PLAIN"];
            player setVariable ["WL_hasHelmetDisplay", false];
        };

        if (_inNetworkRange) then {
            "WLNetwork" cutRsc ["RscWLEWNetworkDisplay", "PLAIN"];
        } else {
            "WLNetwork" cutText ["", "PLAIN"];
        };

        if (_inWhitelistedVehicle) then {
            WL_HelmetInterface = 2;
        } else {
            if (_hasGlasses && _inNetworkRange) then {
                WL_HelmetInterface = 1;
            } else {
                WL_HelmetInterface = 0;
            };
        };
    };
};

0 spawn {
    private _setNewRange = {
        params ["_range"];
        private _gogglesDisplay = uiNamespace getVariable ["RscWLGogglesDisplay", displayNull];
        if (isNull _gogglesDisplay) exitWith {};
        private _rangeControl = _gogglesDisplay displayCtrl 8000;
        _rangeControl ctrlSetText str _range;
    };
    private _helmetInterfaceDistances = [0, 250, 500, 1000, 2500, 5000];
    private _helmetInterfaceIndex = count _helmetInterfaceDistances - 1;

    [_helmetInterfaceDistances # _helmetInterfaceIndex] call _setNewRange;

	while { !BIS_WL_missionEnd && !WL_IsSpectator } do {
        private _hasGoggles = player getVariable ["WL_hasHelmetDisplay", false];
        if (_hasGoggles) then {
            sleep 0.01;
        } else {
            sleep 1;
        };

        if (inputAction "timeDec" > 0) then {
            waitUntil { sleep 0.01; inputAction "timeDec" == 0 };
            _helmetInterfaceIndex = (_helmetInterfaceIndex - 1) max 0;
            private _newMaxDistance = _helmetInterfaceDistances # _helmetInterfaceIndex;
            uiNamespace setVariable ["WL_HelmetInterfaceMaxDistance", _newMaxDistance];
            [_newMaxDistance] call _setNewRange;
            playSoundUI ["a3\sounds_f_mark\arsenal\sfx\bipods\bipod_generic_deploy.wss"];
        };
        if (inputAction "timeInc" > 0) then {
            waitUntil { sleep 0.01; inputAction "timeInc" == 0 };
            _helmetInterfaceIndex = (_helmetInterfaceIndex + 1) min (count _helmetInterfaceDistances - 1);
            private _newMaxDistance = _helmetInterfaceDistances # _helmetInterfaceIndex;
            uiNamespace setVariable ["WL_HelmetInterfaceMaxDistance", _newMaxDistance];
            [_newMaxDistance] call _setNewRange;
            playSoundUI ["a3\sounds_f_mark\arsenal\sfx\bipods\bipod_generic_deploy.wss"];
        };
    };
};