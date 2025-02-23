#include "..\..\warlords_constants.inc"

uiNamespace setVariable ["WL_HelmetInterfaceLaserIcons", []];
uiNamespace setVariable ["WL_HelmetInterfaceFlareIcons", []];
uiNamespace setVariable ["WL_HelmetInterfaceMunitionIcons", []];
uiNamespace setVariable ["WL_HelmetInterfaceTargetVehicleIcons", []];
uiNamespace setVariable ["WL_HelmetInterfaceTargetInfantryIcons", []];
uiNamespace setVariable ["WL_HelmetInterfaceMaxDistance", 5000];

addMissionEventHandler ["Draw3D", {
    if (WL_HelmetInterface == 0) exitWith {};

    private _laserIcons = uiNamespace getVariable ["WL_HelmetInterfaceLaserIcons", []];
    {
        drawIcon3D _x;
    } forEach _laserIcons;

    private _flareIcons = uiNamespace getVariable ["WL_HelmetInterfaceFlareIcons", []];
    {
        drawIcon3D _x;
    } forEach _flareIcons;

    private _munitionIcons = uiNamespace getVariable ["WL_HelmetInterfaceMunitionIcons", []];
    {
        drawIcon3D _x;
    } forEach _munitionIcons;

    private _targetVehicleIcons = uiNamespace getVariable ["WL_HelmetInterfaceTargetVehicleIcons", []];
    {
        drawIcon3D _x;
    } forEach _targetVehicleIcons;

    private _targetInfantryIcons = uiNamespace getVariable ["WL_HelmetInterfaceTargetInfantryIcons", []];
    {
        private _targetPos = _x # 2;
        private _screenPos = worldToScreen _targetPos;
        private _isInViewRadius = count _screenPos == 2 && {
            (_screenPos distance2D [0.5, 0.5]) < 0.2
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

    if (WL_HelmetInterface == 1) exitWith {};

    private _vehicle = getConnectedUAV player;
    if (isNull _vehicle) then {
        _vehicle = vehicle player;
    };
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
        _missile setVariable ["WL_missileApproaching", _missileApproaching];

        private _missileLost = _missile getVariable ["APS_missileLost", false];
        private _color = switch true do {
            case (!_missileApproaching || _missileLost): {
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

        drawIcon3D [
            "\A3\ui_f\data\IGUI\RscCustomInfo\Sensors\Targets\missile_ca.paa",
            _color,
            _missilePos,
            0.8,
            0.8,
            0,
            format ["%1 KM", (round (_distance / 100)) / 10],
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
    private _categoryMap = missionNamespace getVariable ["WL2_categories", createHashMap];

    while { !BIS_WL_missionEnd } do {
        if (WL_HelmetInterface == 2) then {
            sleep 0.1;
        } else {
            sleep 0.5;
        };

        if (WL_HelmetInterface == 0) then {
            continue;
        };

        private _side = BIS_WL_playerSide;
        private _laserTargetSide = switch (_side) do {
            case west: {
                "LaserTargetW"
            };
            case east: {
                "LaserTargetE"
            };
            case independent: {
                "LaserTargetI"
            };
        };
        private _laserTargets = entities _laserTargetSide;
        private _laserIcons = [];
        {
            private _target = _x;
            private _responsiblePlayer = _target getVariable ["WL_laserPlayer", objNull];
            private _playerName = name _responsiblePlayer;
            if (_playerName == "Error: No vehicle") then {
                _playerName = "";
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

        private _vehicle = getConnectedUAV player;
        if (isNull _vehicle) then {
            _vehicle = vehicle player;
        };
        if (!alive _vehicle) then {
            sleep 1;
            continue;
        };

        private _flares = (8 allObjects 2) select {
            typeof _x == "CMflare_Chaff_Ammo"
        };
        private _flareIcons = [];
        {
            private _flare = _x;
            private _flarePos = _flare modelToWorldVisual [0, 0, 0];
            private _distance = _vehicle distance _flare;

            if (_distance > 4000) then {
                continue;
            };

            _flareIcons pushBack [
                "\A3\ui_f\data\IGUI\RscCustomInfo\Sensors\Targets\missileAlt_ca.paa",
                [1, 1, 1, 1],
                _flare modelToWorldVisual [0, 0, 0],
                0.8,
                0.8,
                0
            ];
        } forEach _flares;
        uiNamespace setVariable ["WL_HelmetInterfaceFlareIcons", _flareIcons];

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
            case 1: {
                if (vehicle player == player) then {
                    1000;
                } else {
                    5000;
                };
            };
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
            _x getVariable ["WL_spawnedAsset", false] &&
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
                private _ownerName = name _ownerPlayer;
                if (_ownerName == "Error: No vehicle") then {
                    _ownerName = "";
                };
                format ["%1 (%2)", _assetTypeName, _ownerName];
            } else {
                _assetTypeName;
            };

            if (_targetIsInfantry) then {
                _targetInfantryIcons pushBack [
                    "\A3\ui_f\data\IGUI\RscCustomInfo\Sensors\Targets\UnknownGround_ca.paa",
                    _targetColor,
                    _target modelToWorldVisual (_target selectionPosition "head_hit"),
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
                private _targetIconSize = 1.6;
                if (_assetCategory == "AirDefense") then {
                    _targetIcon = "\A3\ui_f\data\map\markers\nato\b_antiair.paa";
                    _targetIconSize = 1.2;
                } else {
                    _targetIcon = "\A3\ui_f\data\IGUI\Cfg\Cursors\lock_target_ca.paa";
                };

                _targetVehicleIcons pushBack [
                    _targetIcon,
                    _targetColor,
                    _target modelToWorldVisual (getCenterOfMass _target),
                    _targetIconSize,
                    _targetIconSize,
                    0,
                    _assetName,
                    true,
                    0.035,
                    "RobotoCondensedBold",
                    "center",
                    true
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
        if (count _lockedMissiles > 0 && serverTime - _warningPlayed > 1.5) then {
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
            playSoundUI [_soundFile, 5];

            player setVariable ["WL_missileWarningPlayed", serverTime];
        };
    };
};

0 spawn {
    while { !BIS_WL_missionEnd } do {
        sleep 1;

        private _vehicle = getConnectedUAV player;
        if (isNull _vehicle) then {
            _vehicle = vehicle player;
        };

        private _allowedVehicles = missionNamespace getVariable ["WL2_hasHMD", createHashMap];
        private _vehicleActualType = _vehicle getVariable ["WL2_orderedClass", typeOf _vehicle];
        private _inWhitelistedVehicle = _allowedVehicles getOrDefault [_vehicleActualType, false];

        private _sideVehiclesVars = format ["BIS_WL_%1OwnedVehicles", BIS_WL_playerSide];
        private _sideVehicles = missionNamespace getVariable [_sideVehiclesVars, []];
        private _hasAWACSMap = missionNamespace getVariable ["WL2_hasAWACS", createHashMap];

        private _friendlyNetwork = _sideVehicles select {
            private _distance = _vehicle distance _x;
            private _activated = _x getVariable ["WL_ewNetActive", false] && isEngineOn _x;
            private _inJamRange = _distance < WL_JAMMER_RANGE_OUTER;

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

	while { !BIS_WL_missionEnd } do {
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