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
                if (_projectile isKindOf "MissileBase") then {
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
    private _hudRangeIndex = count _hudRangeDistances - 1;

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

        if (_range == 0) exitWith {
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
        ["BACK", "Toggle interface"],
        ["F1", "Toggle help"],
        ["V", "Mute targeted player"]
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

        private _droneViewDistance = _settingsMap getOrDefault ["droneViewDistance", 2000];
        private _spectatorViewDistance = _droneViewDistance * 2;
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
            _camera camCommand "speedDefault 1";
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

        sleep 0.001;
    };
};

0 spawn {
    while { WL_IsSpectator } do {
        private _maxDistance = uiNamespace getVariable ["WL_SpectatorHudMaxDistance", 10000];

        private _drawIcons = [];
        // private _drawLines = [];

        private _categoryMap = missionNamespace getVariable ["WL2_categories", createHashMap];
        private _camera = missionNamespace getVariable ["BIS_EGSpectatorCamera_camera", objNull];
        private _laserTargets = entities "LaserTarget";
        {
            private _target = _x;

            if (_x distance _camera > _maxDistance) then {
                continue;
            };

            private _responsiblePlayer = _target getVariable ["WL_laserPlayer", objNull];
            if (isNull _responsiblePlayer) then {
                continue;
            };
            private _playerName = name _responsiblePlayer;
            if (_playerName == "Error: No vehicle") then {
               _playerName = "";
            };
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

        private _cameraPos = positionCameraToWorld [0, 0, 0];

        private _targets = (vehicles + allUnits) select {
            alive _x &&
            lifeState _x != "INCAPACITATED" &&
            (_x getVariable ["WL_spawnedAsset", false] || isPlayer _x) &&
            _cameraPos distance _x < _maxDistance;
        };

        {
            private _target = _x;
            private _targetIsInfantry = _target isKindOf "Man";

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
            if (_distance > _maxDistance) then {
                continue;
            };

            private _lastFiredTime = _target getVariable ["WL2_spectateLastFired", -1];
            private _opacity = linearConversion [0, 0.5, serverTime - _lastFiredTime, 0, 1, true];
            _targetColor set [3, _opacity];

            if (_targetIsInfantry) then {
                if (_distance > 500) then {
                    continue;
                };
                _drawIcons pushBack [
                    "\A3\ui_f\data\IGUI\RscCustomInfo\Sensors\Targets\UnknownGround_ca.paa",
                    _targetColor,
                    _target modelToWorldVisual (_target selectionPosition "spine2"),
                    0.5,
                    0.5,
                    45,
                    if (_distance < 50) then {
                        _assetName
                    } else {
                        ""
                    },
                    true,
                    0.03,
                    "RobotoCondensedBold"
                ];
            } else {
                _assetName = format ["%1 [%2 KM]", _assetName, (round (_distance / 100)) / 10];

                private _assetActualType = _target getVariable ["WL2_orderedClass", typeof _target];

                private _targetIcon = getText (configFile >> "CfgVehicles" >> typeOf _target >> "picture");
                if (_targetIcon == "" || _targetIcon == "picturething") then {
                    _targetIcon = "\A3\ui_f\data\IGUI\RscCustomInfo\Sensors\Targets\Air_ca.paa";
                };
                private _targetIconInfo = getTextureInfo _targetIcon;
                private _targetIconRatio = _targetIconInfo # 0 / _targetIconInfo # 1;

                private _iconSize = linearConversion [0, 5000, _distance, 1.0, 0.3];
                private _iconTextSize = linearConversion [0, 5000, _distance, 0.035, 0.03];
                private _iconPos = _target modelToWorldVisual (getCenterOfMass _target);
                _drawIcons pushBack [
                    _targetIcon,
                    _targetColor,
                    _iconPos,
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

                // private _directionVehicle = vectorDir _target;
                // private _directionWeapon = _target weaponDirection currentWeapon _target;
                // {
                //     private _getEndpoint = (_x vectorMultiply 1000) vectorAdd _iconPos;
                //     private _intersection = lineIntersectsSurfaces [
                //         AGLtoASL _iconPos,
                //         AGLtoASL _getEndpoint,
                //         _target
                //     ];
                //     private _getIntersectPoint = if (count _intersection > 0) then {
                //         (_intersection # 0) # 0
                //     } else {
                //         _getEndpoint
                //     };
                //     _drawLines pushBack [
                //         _iconPos,
                //         ASLtoAGL _getIntersectPoint,
                //         _targetColor,
                //         5
                //     ];
                // } forEach [_directionVehicle, _directionWeapon];
            };
        } forEach _targets;

        private _projectiles = uiNamespace getVariable ["WL2_projectiles", []];
        {
            private _missile = _x;
            private _missilePos = _missile modelToWorldVisual [0, 0, 0];
            private _distance = _missile distance _cameraPos;
            if (_distance > _maxDistance) then {
                continue;
            };

            _drawIcons pushBack [
                "\A3\ui_f\data\IGUI\RscCustomInfo\Sensors\Targets\missile_ca.paa",
                [1, 0, 0, 1],
                _missilePos,
                0.8,
                0.8,
                0,
                format ["%1 KM", (_distance / 1000) toFixed 1],
                true,
                0.035,
                "RobotoCondensedBold",
                "center",
                true
            ];
        } forEach _projectiles;
        uiNamespace setVariable ["WL2_spectatorDrawIcons", _drawIcons];

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

            _drawIcons pushBack [
                _sectorIcon,
                _sectorColor,
                _sectorPos,
                1,
                1,
                0,
                _sectorName,
                true,
                0.04,
                "RobotoCondensedBold"
            ];
        } forEach BIS_WL_allSectors;
        // uiNamespace setVariable ["WL2_spectatorDrawLines", _drawLines];

        sleep 0.001;
    };
};