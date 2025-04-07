WL_IsSpectator = true;

player setVariable ["ShowHeader", false];
player setVariable ["ShowCameraButtons", false];
player setVariable ["ShowControlsHelper", false];
["Initialize", [player, [], true]] call BIS_fnc_EGSpectator;

private _displayId = 60492;
[_displayId] spawn GFE_fnc_earplugs;

// hide spectator on land
player setPosASL [2304.97, 9243.11, 11.5];
player allowDamage false;

private _sectors = [BIS_WL_allSectors, [], { _x getVariable "BIS_WL_name" }, "ASCEND"] call BIS_fnc_sortBy;

private _osdDisplay = uiNamespace getVariable "RscTitleDisplayEmpty";
_osdDisplay closeDisplay 0;

addMissionEventHandler ["Draw3D", {
    private _drawIcons = uiNamespace getVariable ["WL2_spectatorDrawIcons", []];
    // private _drawLines = uiNamespace getVariable ["WL2_spectatorDrawLines", []];

    {
        drawIcon3D _x;
    } forEach _drawIcons;

    // {
    //     drawLine3D _x;
    // } forEach _drawLines;
}];

0 spawn {
    private _projectiles = [];
    uiNamespace setVariable ["WL2_projectiles", _projectiles];
    private _camera = missionNamespace getVariable ["BIS_EGSpectatorCamera_camera", objNull];

    while { WL_IsSpectator } do {
        private _maxDistance = uiNamespace getVariable ["WL_SpectatorHudMaxDistance", 10000];
        private _allVehicles = (vehicles + allUnits);

        _projectiles = _projectiles select {
            alive _x && _x distance _camera < _maxDistance
        };

        {
            private _vehicle = _x;

            private _unitSpawnedEventListener = _vehicle getVariable ["WL2_unitSpawnedEventListener", false];
            if (_unitSpawnedEventListener) then {
                continue;
            };
            _vehicle setVariable ["WL2_unitSpawnedEventListener", true];

            _vehicle addEventHandler ["Fired", {
                params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_gunner"];
                if (!WL_IsSpectator) exitWith {};
                private _projectiles = uiNamespace getVariable ["WL2_projectiles", []];
                _unit setVariable ["WL2_spectateLastFired", serverTime];
                if ([_projectile] call WL2_fnc_isScannerMunition) then {
                    _projectiles pushBack _projectile;
                };
            }];
        } forEach _allVehicles;
        sleep 5;
    };
};

0 spawn {
    private _spectatingPlayer = objNull;
    private _spectatingPlayerScore = -1;
    while { WL_IsSpectator } do {
        private _spectatorFocus = uiNamespace getVariable ["RscEGSpectator_focus", objNull];
        private _currentSpectatingPlayer = [_spectatorFocus, _spectatorFocus] call WL2_fnc_handleInstigator;
        private _currentScore = score _spectatingPlayer;

        if (_currentSpectatingPlayer != _spectatingPlayer) then {
            _spectatingPlayer = _currentSpectatingPlayer;
            _spectatingPlayerScore = _currentScore;
        } else {
            if (_currentScore != _spectatingPlayerScore) then {
                _spectatingPlayerScore = _currentScore;
                playSoundUI ["hitmarker", 1, 1];
            };
        };

        if (inputAction "GetOver" > 0) then {
            waitUntil { inputAction "GetOver" == 0 };
            private _volume = getPlayerVoNVolume _spectatingPlayer;
            if (_volume == -1) then {
                continue;
            } else {
                if (_volume == 0) then {
                    _spectatingPlayer setPlayerVoNVolume 1;
                } else {
                    _spectatingPlayer setPlayerVoNVolume 0;
                };
            };
        };

        sleep 0.001;
    };
};

0 spawn {
    private _hudRangeDistances = [0, 250, 500, 1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000, 10000];
    private _hudRangeIndex = 7;

    removeMissionEventHandler ["Draw3D", BIS_EGSpectator_draw3D];

    private _setNewRange = {
        params ["_range"];
        private _gogglesDisplay = uiNamespace getVariable ["RscWLGogglesDisplay", displayNull];
        if (isNull _gogglesDisplay) then {
            "WLGoggles" cutRsc ["RscWLGogglesDisplay", "PLAIN"];
            _gogglesDisplay = uiNamespace getVariable ["RscWLGogglesDisplay", displayNull];
        };
        private _rangeControl = _gogglesDisplay displayCtrl 8000;
        _rangeControl ctrlSetText str _range;

        if (_range == 0) then {
            _gogglesDisplay closeDisplay 0;
            uiNamespace setVariable ["RscWLGogglesDisplay", displayNull];
        };

        uiNamespace setVariable ["WL_SpectatorHudMaxDistance", _range];
        playSoundUI ["a3\sounds_f_mark\arsenal\sfx\bipods\bipod_generic_deploy.wss"];
    };
    [_hudRangeDistances # _hudRangeIndex] call _setNewRange;

    private _spectatorDisplay = findDisplay 60492;
    private _spectatorDisplayMap = _spectatorDisplay displayCtrl 62609;
    private _mapGroup = ctrlParentControlsGroup _spectatorDisplayMap;

    _mapGroup ctrlShow false;
    _mapGroup ctrlSetPosition [0, 0, 0, 0];
    _mapGroup ctrlCommit 0;

    _spectatorDisplayMap ctrlShow false;
    _spectatorDisplayMap ctrlSetPosition [0, 0, 0, 0];
    _spectatorDisplayMap ctrlCommit 0;

    private _spectatorDisplay = findDisplay 60492;

    private _camera = missionNamespace getVariable ["BIS_EGSpectatorCamera_camera", objNull];
    _camera camCommand "speedMax 4";

    private _mapDisplay = _spectatorDisplay ctrlCreate ["RscMapControl", -1];
    _mapDisplay ctrlCommit 0;
    _mapDisplay ctrlMapSetPosition [safeZoneX, safeZoneY, safeZoneW, safeZoneH];
    _mapDisplay ctrlMapAnimAdd [0, 0.2, getPosASL _camera];
    ctrlMapAnimCommit _mapDisplay;
    _mapDisplay ctrlAddEventHandler ["Draw", WL2_fnc_iconDrawMap];
    _mapDisplay ctrlShow false;

    _mapDisplay ctrlAddEventHandler ["Draw", {
        params ["_map"];
        private _start = uiNamespace getVariable ["WL2_spectatorMouseClickStart", []];
        if (count _start == 0) exitWith {};

        private _posStart = _map ctrlMapScreenToWorld _start;
        private _posEnd = _map ctrlMapScreenToWorld getMousePosition;

        if (_posStart distance2D _posEnd > 100) then {
            _map drawArrow [
                _posStart,
                _posEnd,
                [1, 0, 0, 1]
            ];
        };
    }];

    _mapDisplay ctrlAddEventHandler ["MouseButtonDown", {
        params ["_map", "_button", "_xPos", "_yPos", "_shift", "_ctrl", "_alt"];
        if (_button != 0) exitWith {};
        // Start map drag
        uiNamespace setVariable ["WL2_spectatorMouseClickStart", [_xPos, _yPos]];
    }];

    _mapDisplay ctrlAddEventHandler ["MouseButtonUp", {
        params ["_map", "_button", "_xPos", "_yPos", "_shift", "_ctrl", "_alt"];
        if (_button != 0) exitWith {};

        private _start = uiNamespace getVariable ["WL2_spectatorMouseClickStart", []];
        if (count _start == 0) exitWith {};
        uiNamespace setVariable ["WL2_spectatorMouseClickStart", []];

        // Reset to free cam in scripts
        private _cameraScript = missionNamespace getVariable ["BIS_fnc_EGSpectatorCamera", {}];
        private _cameraResetScript = missionNamespace getVariable ["BIS_fnc_EGSpectatorCameraResetTarget", {}];
        private _spectatorScript = uiNamespace getVariable ["RscDisplayEGSpectator_script", {}];
        ["SetCameraMode", ["free"]] call _cameraScript;
        [] call _cameraResetScript;
        ["TreeUnselect"] call _spectatorScript;
        ["ShowFocusInfoWidget", [false]] call _spectatorScript;

        // Remove focus
        uiNamespace setVariable ["RscEGSpectator_focus", objNull];

        private _camera = missionNamespace getVariable ["BIS_EGSpectatorCamera_camera", objNull];
        private _posStart = _map ctrlMapScreenToWorld _start;
        _posStart set [2, (getPosATL _camera) # 2];

        private _posEnd = _map ctrlMapScreenToWorld [_xPos, _yPos];
        _posEnd set [2, 0];

        if (_posStart distance2D _posEnd > 100) then {
            private _targetVectorDirAndUp = [_posStart, _posEnd] call BIS_fnc_findLookAt;
            _camera setVectorDirAndUp _targetVectorDirAndUp;
        };

        _camera setPosATL _posStart;
    }];

    private _instructionsDisplay = _spectatorDisplay ctrlCreate ["RscStructuredText", -1];
    _instructionsDisplay ctrlSetPosition [
        1 - safeZoneX - 0.4 - 0.05,
        1 - safeZoneY - 0.5 - 0.05,
        0.4,
        0.6
    ];
    _instructionsDisplay ctrlSetTextColor [1, 1, 1, 1];

    private _instructionStages = [
        ["W/S", "Forward/Back"],
        ["A/D", "Left/Right"],
        ["Q/Z", "Up/Down"],
        ["RMB", "Camera rotate"],
        ["M", "Toggle map"],
        ["SHIFT", "Faster"],
        ["ALT", "Slower"],
        ["SPACE", "Camera mode"],
        ["=/-", "HUD range"],
        ["V", "Mute targeted player"],
        ["BACK", "Toggle interface"],
        ["F1", "Toggle help"],
        ["K", "Settings menu"]
    ];

    _instructionStages = _instructionStages apply {
        private _action = _x # 0;
        private _text = _x # 1;
        format ["<t align='left'>%1</t><t align='right'>[%2]</t>", _text, _action];
    };
    private _instructionText = _instructionStages joinString "<br/>";

    _instructionsDisplay ctrlSetStructuredText parseText format [
        "<t size='1'>%1</t>",
        _instructionText
    ];
    _instructionsDisplay ctrlCommit 0;

    private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];

    while { WL_IsSpectator } do {
        if (inputAction "timeDec" > 0) then {
            waitUntil { inputAction "timeDec" == 0 };
            _hudRangeIndex = (_hudRangeIndex - 1) max 0;
            private _newMaxDistance = _hudRangeDistances # _hudRangeIndex;
            [_newMaxDistance] call _setNewRange;
        };
        if (inputAction "timeInc" > 0) then {
            waitUntil { inputAction "timeInc" == 0 };
            _hudRangeIndex = (_hudRangeIndex + 1) min (count _hudRangeDistances - 1);
            private _newMaxDistance = _hudRangeDistances # _hudRangeIndex;
            [_newMaxDistance] call _setNewRange;
        };

        private _infantryViewDistance = _settingsMap getOrDefault ["infantryViewDistance", 2000];
        private _spectatorViewDistance = _infantryViewDistance * 2;
        if (viewDistance != _spectatorViewDistance) then {
            setViewDistance _spectatorViewDistance;
            setObjectViewDistance [_spectatorViewDistance, 5];
        };

        private _mapButtonClick = uiNamespace getVariable ["RscEGSpectator_mapMouseButtonClick", -1];
        if (_mapButtonClick != -1) then {
            _mapGroup ctrlShow false;
            uiNamespace setVariable ["RscEGSpectator_mapMouseButtonClick", -1];
        };

        private _mapVisible = uiNamespace getVariable ["RscEGSpectator_mapVisible", false];
        _mapDisplay ctrlShow _mapVisible;

        if (inputAction "lookAround" > 0) then {
            _camera camCommand "speedDefault 0.5";
        } else {
            _camera camCommand "speedDefault 15";
        };

        private _interfaceVisible = uiNamespace getVariable ["RscEGSpectator_interfaceVisible", false];
        private _helpVisible = uinamespace getVariable ["RscEGSpectator_controlsHelpVisible", false];   // opposite due to init
        if (!_helpVisible && _interfaceVisible) then {
            _instructionsDisplay ctrlShow true;
        } else {
            _instructionsDisplay ctrlShow false;
        };

        if (inputAction "compass" > 0) then {
            waitUntil { inputAction "compass" == 0 };
            call MENU_fnc_settingsMenuInit;
        };

        sleep 0.001;
    };
};

0 spawn {
    while { WL_IsSpectator } do {
        private _maxDistance = uiNamespace getVariable ["WL_SpectatorHudMaxDistance", 10000];
        private _camera = missionNamespace getVariable ["BIS_EGSpectatorCamera_camera", objNull];
        private _cameraPos = positionCameraToWorld [0, 0, 0];

        private _laserTargets = entities "LaserTarget";
        _laserTargets = _laserTargets select {
            alive _x &&
            _x distance _cameraPos <= _maxDistance &&
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
            alive _x &&
            lifeState _x != "INCAPACITATED" &&
            _x distance _cameraPos <= _maxDistance &&
            simulationEnabled _x &&
            !(_x isKindOf "LaserTarget");
        };

        private _vehicles = [];
        private _infantry = [];
        {
            private _target = _x;

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
                    [1, 1, 1, 1]
                };
            };

            private _assetTypeName = [_target] call WL2_fnc_getAssetTypeName;

            private _ownerPlayer = (_target getVariable ["BIS_WL_ownerAsset", "123"]) call BIS_fnc_getUnitByUID;
            private _ownerName = if (isNull _ownerPlayer) then {
                "";
            } else {
                name _ownerPlayer;
            };
            if (_ownerName == "Error: No vehicle") then {
                _ownerName = "";
            };
            private _assetName = if (_ownerName == "") then {
                _assetTypeName
            } else {
                format ["%1 (%2)", _assetTypeName, _ownerName]
            };

            private _distance = _cameraPos distance _target;
            if (_target isKindOf "Man") then {
                if (_distance > 50) then {
                    _assetName = "";
                };
                if (_distance > 500) then {
                    continue;
                };
                _infantry pushBack [
                    _target,
                    _targetColor,
                    _assetName
                ];
            } else {
                _assetName = format ["%1 [%2 KM]", _assetName, (round (_distance / 100)) / 10];

                private _assetActualType = _target getVariable ["WL2_orderedClass", typeof _target];

                private _targetIcon = getText (configFile >> "CfgVehicles" >> typeOf _target >> "picture");
                if (_targetIcon in ["", "picturething", "pictureThing", "picturelogic", "pictureLogic"]) then {
                    _targetIcon = "\A3\ui_f\data\IGUI\RscCustomInfo\Sensors\Targets\Air_ca.paa";
                };
                private _targetIconInfo = getTextureInfo _targetIcon;
                private _targetIconRatio = _targetIconInfo # 0 / _targetIconInfo # 1;

                private _iconSize = linearConversion [0, 5000, _distance, 1.0, 0.3];
                private _iconTextSize = linearConversion [0, 5000, _distance, 0.035, 0.03];

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

        private _projectiles = uiNamespace getVariable ["WL2_projectiles", []];
        _projectiles = _projectiles select {
            alive _x && _x distance _cameraPos <= _maxDistance
        };

        private _sectors = [];
        {
            private _sector = _x;
            private _sectorArea = _sector getVariable "objectAreaComplete";
            private _sectorPos = _sectorArea # 0;
            _sectorPos set [2, 200];
            private _distance = _cameraPos distance _sectorPos;
            if (_distance > _maxDistance / 2) then {
                continue;
            };
            private _sectorName = _sector getVariable ["BIS_WL_name", "Sector"];
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
                _sectorPos,
                _sectorName
            ];
        } forEach BIS_WL_allSectors;

        uiNamespace setVariable ["WL2_spectatorDrawLasers", _laserTargets];
        uiNamespace setVariable ["WL2_spectatorDrawInfantry", _infantry];
        uiNamespace setVariable ["WL2_spectatorDrawVehicles", _vehicles];
        uiNamespace setVariable ["WL2_spectatorDrawProjectiles", _projectiles];
        uiNamespace setVariable ["WL2_spectatorDrawSectors", _sectors];

        sleep 0.5;
    };
};

0 spawn {
    while { WL_IsSpectator } do {
        private _drawIcons = [];

        private _laserTargets = uiNamespace getVariable ["WL2_spectatorDrawLasers", []];
        private _infantry = uiNamespace getVariable ["WL2_spectatorDrawInfantry", []];
        private _vehicles = uiNamespace getVariable ["WL2_spectatorDrawVehicles", []];
        private _projectiles = uiNamespace getVariable ["WL2_spectatorDrawProjectiles", []];
        private _sectors = uiNamespace getVariable ["WL2_spectatorDrawSectors", []];

        {
            private _target = _x # 0;
            private _playerName = _x # 1;
            _drawIcons pushBack [
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

        {
            private _target = _x # 0;
            private _targetColor = _x # 1;
            private _assetName = _x # 2;

            private _lastFiredTime = _target getVariable ["WL2_spectateLastFired", -1];
            private _opacity = linearConversion [0, 0.5, serverTime - _lastFiredTime, 0, 1, true];
            _targetColor set [3, _opacity];

            _drawIcons pushBack [
                "\A3\ui_f\data\IGUI\RscCustomInfo\Sensors\Targets\UnknownGround_ca.paa",
                _targetColor,
                _target modelToWorldVisual (_target selectionPosition "spine2"),
                0.5,
                0.5,
                45,
                _assetName,
                true,
                0.03,
                "RobotoCondensedBold"
            ];
        } forEach _infantry;

        {
            private _target = _x # 0;
            private _targetIcon = _x # 1;
            private _targetColor = _x # 2;
            private _iconSize = _x # 3;
            private _targetIconRatio = _x # 4;
            private _assetName = _x # 5;
            private _iconTextSize = _x # 6;

            private _lastFiredTime = _target getVariable ["WL2_spectateLastFired", -1];
            private _opacity = linearConversion [0, 0.5, serverTime - _lastFiredTime, 0, 0.6, true];
            _targetColor set [3, _opacity];

            _drawIcons pushBack [
                _targetIcon,
                _targetColor,
                _target modelToWorldVisual (getCenterOfMass _target),
                _iconSize * _targetIconRatio,
                _iconSize,
                0,
                _assetName,
                true,
                _iconTextSize,
                "RobotoCondensedBold",
                "center",
                true
            ];
        } forEach _vehicles;

        {
            _drawIcons pushBack [
                "\A3\ui_f\data\IGUI\RscCustomInfo\Sensors\Targets\missile_ca.paa",
                [1, 0, 0, 1],
                _x modelToWorldVisual [0, 0, 0],
                0.8,
                0.8,
                0,
                "",
                true,
                0.035,
                "RobotoCondensedBold",
                "center",
                true
            ];
        } forEach _projectiles;

        private _cameraPos = positionCameraToWorld [0, 0, 0];
        {
            private _sector = _x # 0;
            private _sectorIcon = _x # 1;
            private _sectorColor = _x # 2;
            private _sectorPos = _x # 3;
            private _sectorName = _x # 4;

            private _distance = _cameraPos distance _sectorPos;
            private _sectorIconSize = linearConversion [200, 2000, _distance, 1.2, 0.3, true];

            _drawIcons pushBack [
                _sectorIcon,
                _sectorColor,
                _sectorPos,
                _sectorIconSize,
                _sectorIconSize,
                0,
                _sectorName,
                true,
                0.04 * _sectorIconSize,
                "RobotoCondensedBold"
            ];
        } forEach _sectors;

        uiNamespace setVariable ["WL2_spectatorDrawIcons", _drawIcons];

        sleep 0.001;
    };
};