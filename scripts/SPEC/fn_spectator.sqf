#include "includes.inc"

private _result = [
	"Enter spectator mode",
	"Once you enter spectator mode, you will no longer be able to go back without logging out and back in again. Do you wish to proceed?",
	"Spectate", "Don't spectate"
] call WL2_fnc_prompt;
if (!_result) exitWith {
    private _uid = getPlayerUID player;
    private _isAdmin = _uid in (getArray (missionConfigFile >> "adminIDs"));
    if (_isAdmin) then {
        private _specExit = profileNamespace getVariable ["WL2_specExit", {}];
        call _specExit;
    };
};

if (WL_IsSpectator) exitWith {};
WL_IsSpectator = true;

// hide spectator on land
player setPosASL [2304.97, 9243.11, 11.5];

private _missionSpectators = missionNamespace getVariable ["WL2_spectators", []];
_missionSpectators pushBackUnique player;
_missionSpectators = _missionSpectators select { !isNull _x };
missionNamespace setVariable ["WL2_spectators", _missionSpectators, true];

player setVariable ["WL2_alreadyHandled", true, true];

setPlayerRespawnTime 10000000;
forceRespawn player;
[player] remoteExec ["WL2_fnc_hideObjectOnAll", 2];

player removeAllEventHandlers "HandleDamage";

{
    private _sector = _x;
    _sector setVariable ["WL2_sectorSelectionAvailable", false];
} forEach BIS_WL_allSectors;

0 spawn {
    while { WL_IsSpectator } do {
        uiSleep 1;
        private _respawnCounter = uiNamespace getVariable ["RscRespawnCounter", displayNull];
        if (!isNull _respawnCounter) then {
            _respawnCounter closeDisplay 1;
        };
    };
};

private _osdDisplay = uiNamespace getVariable ["RscTitleDisplayEmpty", displayNull];
_osdDisplay closeDisplay 0;

private _camera = "camera" camCreate (position player);
_camera camCommit 0;
_camera switchCamera "INTERNAL";

uiNamespace setVariable ["SPEC_Camera", _camera];
uiNamespace setVariable ["SPEC_NightVisionMode", 0];

addMissionEventHandler ["EachFrame", {
    private _camera = uiNamespace getVariable ["SPEC_Camera", objNull];
    if (isNull _camera) exitWith {};

    private _currentTarget = uiNamespace getVariable ["SPEC_CameraTarget", objNull];

    if (cameraView != "Internal") then {
        _camera switchCamera "Internal";
    };

    private _lastFrameTime = uiNamespace getVariable ["SPEC_LastFrameTime", serverTime];
    private _deltaTime = (serverTime - _lastFrameTime) min 1;

    if (isNull _currentTarget) then {
        if (cameraOn != _camera) then {
            _camera switchCamera "Internal";
        };
        [_camera, _deltaTime] call SPEC_fnc_spectatorFree;
    } else {
        [_camera, _deltaTime, _currentTarget] call SPEC_fnc_spectator3P;
    };

    uiNamespace setVariable ["SPEC_LastFrameTime", serverTime];
}];

private _mainDisplay = findDisplay 46;
_mainDisplay displayAddEventHandler ["KeyDown", {
    params ["_displayOrControl", "_key", "_shift", "_ctrl", "_alt"];

    if (_key in actionKeys "cameraMoveRight") exitWith {
        uiNamespace setVariable ["SPEC_CameraMoveRight", 1];
    };
    if (_key in actionKeys "cameraMoveLeft") exitWith {
        uiNamespace setVariable ["SPEC_CameraMoveLeft", 1];
    };
    if (_key in actionKeys "cameraMoveForward") exitWith {
        uiNamespace setVariable ["SPEC_CameraMoveForward", 1];
    };
    if (_key in actionKeys "cameraMoveBackward") exitWith {
        uiNamespace setVariable ["SPEC_CameraMoveBackward", 1];
    };
    if (_key in actionKeys "cameraMoveUp") exitWith {
        uiNamespace setVariable ["SPEC_CameraMoveUp", 1];
    };
    if (_key in actionKeys "cameraMoveDown") exitWith {
        uiNamespace setVariable ["SPEC_CameraMoveDown", 1];
    };

    if (_key in actionKeys "BuldLeft") exitWith {
        private _camera = uiNamespace getVariable ["SPEC_Camera", objNull];
        private _eligibleTargets = (allUnits + allDeadMen) select { simulationEnabled _x };
        private _currentTarget = uiNamespace getVariable ["SPEC_CameraTarget", objNull];
        private _currentTargetIndex = _eligibleTargets find _currentTarget;
        _currentTargetIndex = (_currentTargetIndex - 1) max -1;
        if (_currentTargetIndex != -1) then {
            private _newTarget = _eligibleTargets select _currentTargetIndex;
            [_newTarget] call SPEC_fnc_spectatorSelectTarget;
        } else {
            [objNull] call SPEC_fnc_spectatorSelectTarget;
        };
    };
    if (_key in actionKeys "BuldRight") exitWith {
        private _camera = uiNamespace getVariable ["SPEC_Camera", objNull];
        private _eligibleTargets = (allUnits + allDeadMen) select { simulationEnabled _x };
        private _currentTarget = uiNamespace getVariable ["SPEC_CameraTarget", objNull];
        private _currentTargetIndex = _eligibleTargets find _currentTarget;
        _currentTargetIndex = (_currentTargetIndex + 1) min (count _eligibleTargets - 1);
        private _newTarget = _eligibleTargets select _currentTargetIndex;
        [_newTarget] call SPEC_fnc_spectatorSelectTarget;
    };

    if (_key in actionKeys "personView") exitWith {
        private _targetCamMode = uiNamespace getVariable ["SPEC_TargetCameraMode", 0];
        private _currentTarget = uiNamespace getVariable ["SPEC_CameraTarget", objNull];
        _targetCamMode = if (isNull _currentTarget) then { 0 } else {
            (_targetCamMode + 1) mod 4;
        };

        uiNamespace setVariable ["SPEC_TargetCameraMode", _targetCamMode];

        private _spectatorInfo = uiNamespace getVariable ["RscWLSpectatorInfo", displayNull];
        private _spectatorMode = _spectatorInfo displayCtrl 104;
        private _modes = ["Bird Eye", "First Person", "Third Person", "Gunner"];
        private _modeText = _modes select _targetCamMode;
        _spectatorMode ctrlSetStructuredText parseText format ["<t shadow='2'>Mode: %1</t>", _modeText];
        true;
    };

    if (_key in actionKeys "nextWeapon") exitWith {
        0 spawn SPEC_fnc_spectatorTargetMenu;
    };

    if (_key in actionKeys "lockTarget") exitWith {
        private _currentTarget = uiNamespace getVariable ["SPEC_CameraTarget", objNull];
        if (!isNull _currentTarget) exitWith {
            [objNull] call SPEC_fnc_spectatorSelectTarget;
        };

        private _fromPos = getPosASL cameraOn;
        private _toPos = ((cameraOn screenToWorldDirection [0.5, 0.5]) vectorMultiply 1000) vectorAdd _fromPos;

        private _intersects = lineIntersectsSurfaces [_fromPos, _toPos, objNull, objNull, true, 1];

        private _newTarget = if (count _intersects > 0) then {
            _intersects select 0 select 3;
        } else {
            objNull;
        };

        if (isNull _newTarget) then {
            private _spot = screenToWorld [0.5, 0.5];
            private _objects = nearestObjects [_spot, ["AllVehicles", "Man"], 10];
            if (count _objects > 0) then {
                _newTarget = _objects select 0;
            };
        };

        if !(isNull _newTarget) then {
            [_newTarget] call SPEC_fnc_spectatorSelectTarget;
        };
    };
}];

_mainDisplay displayAddEventHandler ["KeyUp", {
    params ["_displayOrControl", "_key", "_shift", "_ctrl", "_alt"];

    if (_alt) then {
        private _existingValue = uiNamespace getVariable ["WL2_isHoldingAlt", false];
        uiNamespace setVariable ["WL2_isHoldingAlt", !_existingValue];
    };

    if (_key in actionKeys "cameraMoveRight") exitWith {
        uiNamespace setVariable ["SPEC_CameraMoveRight", 0];
    };
    if (_key in actionKeys "cameraMoveLeft") exitWith {
        uiNamespace setVariable ["SPEC_CameraMoveLeft", 0];
    };
    if (_key in actionKeys "cameraMoveForward") exitWith {
        uiNamespace setVariable ["SPEC_CameraMoveForward", 0];
    };
    if (_key in actionKeys "cameraMoveBackward") exitWith {
        uiNamespace setVariable ["SPEC_CameraMoveBackward", 0];
    };
    if (_key in actionKeys "cameraMoveUp") exitWith {
        uiNamespace setVariable ["SPEC_CameraMoveUp", 0];
    };
    if (_key in actionKeys "cameraMoveDown") exitWith {
        uiNamespace setVariable ["SPEC_CameraMoveDown", 0];
    };

    if (_key in actionKeys "binocular") exitWith {
        private _display = uiNamespace getVariable ["RscWLHmdSettingDisplay", displayNull];
        if (isNull _display) then {
            0 spawn WL2_fnc_hmdSettings;
        } else {
            "hmd" cutText ["", "PLAIN"];
        };
    };

    if (_key in actionKeys "MoveUp") exitWith {
        private _currentTarget = uiNamespace getVariable ["SPEC_CameraTarget", objNull];
        if (isNull _currentTarget) exitWith {};

        private _isValidProjectile = {
            params ["_projectile"];
            if (!alive _projectile) exitWith { false; };
            if (_projectile isKindOf "MissileCore") exitWith { true; };
            if (_projectile isKindOf "RocketCore") exitWith { true; };
            if (_projectile isKindOf "BombCore") exitWith { true; };
            if (_projectile isKindOf "ShellCore") exitWith { true; };
            if (_projectile isKindOf "SubmunitionCore") exitWith { true; };
            false;
        };

        private _targetIsProjectile = [_currentTarget] call _isValidProjectile;
        private _currentTargetUid = if (_targetIsProjectile) then {
            private _shotParents = getShotParents _currentTarget;
            private _instigator = _shotParents call WL2_fnc_handleInstigator;
            getPlayerUID _instigator;
        } else {
            _currentTarget getVariable ["BIS_WL_ownerAsset", "123"];
        };

        private _munitions = (8 allObjects 2) select {
            [_x] call _isValidProjectile
        } select {
            private _shotParents = getShotParents _x;
            if (count _shotParents == 0) exitWith { false };
            private _instigator = _shotParents call WL2_fnc_handleInstigator;
            getPlayerUID _instigator == _currentTargetUid;
        };
		_munitions = [_munitions, [], { (getShotInfo _x) # 0 }, "DESCEND"] call BIS_fnc_sortBy;
        if (count _munitions == 0) exitWith {};

        private _munitionIndex = if (_targetIsProjectile) then {
            _munitions find _currentTarget;
        } else {
            -1;
        };
        _munitionIndex = (_munitionIndex + 1) mod count _munitions;
        private _newTarget = _munitions select _munitionIndex;
        [_newTarget] call SPEC_fnc_spectatorSelectTarget;
    };

    if (_key in actionKeys "showMap") exitWith {
        call SPEC_fnc_spectatorMap;
    };

    if (_key in actionKeys "ListLeftVehicleDisplay") exitWith {
        private _showControlsInfo = uiNamespace getVariable ["SPEC_ShowControlsInfo", true];
        _showControlsInfo = !_showControlsInfo;
        uiNamespace setVariable ["SPEC_ShowControlsInfo", _showControlsInfo];
    };

    if (_key in actionKeys "ListRightVehicleDisplay") exitWith {
        private _showTargetInfo = uiNamespace getVariable ["SPEC_ShowTargetInfo", true];
        _showTargetInfo = !_showTargetInfo;
        uiNamespace setVariable ["SPEC_ShowTargetInfo", _showTargetInfo];
    };

    if (_key in actionKeys "nightVision") exitWith {
        private _drawingMap = uiNamespace getVariable ["WL2_drawingMap", false];
        if (_drawingMap) exitWith {};
        private _currentVisionMode = uiNamespace getVariable ["SPEC_NightVisionMode", 0];
        _currentVisionMode = (_currentVisionMode + 1) mod 3;
        uiNamespace setVariable ["SPEC_NightVisionMode", _currentVisionMode];

        switch (_currentVisionMode) do {
            case 0: {
                camUseNVG false;
                false setCamUseTI 0;
            };
            case 1: {
                camUseNVG true;
            };
            case 2: {
                true setCamUseTI 0;
            };
        };
    };

    if (_key in actionKeys "getOver") exitWith {
        private _vonMuted = uiNamespace getVariable ["SPEC_VoNMuted", false];
        if (_vonMuted) then {
            playSoundUI ["a3\sounds_f_bootcamp\sfx\vr\simulation_restart.wss"];
            {
                _x setPlayerVoNVolume 1;
            } forEach allPlayers;
        } else {
            playSoundUI ["a3\sounds_f_bootcamp\sfx\vr\simulation_fatal.wss"];
            {
                _x setPlayerVoNVolume 0;
            } forEach allPlayers;
        };
        _vonMuted = !_vonMuted;
        uiNamespace setVariable ["SPEC_VoNMuted", _vonMuted];
    };

    if (_key in actionKeys "SelectGroupUnit1") exitWith {
        private _hideInterface = uiNamespace getVariable ["SPEC_HideInterface", false];
        uiNamespace setVariable ["SPEC_HideInterface", !_hideInterface];
    };

    if (_key in actionKeys "compass") exitWith {
        [] spawn MENU_fnc_settingsMenuInit;
    };
}];

openMap [false, true];

0 spawn SPEC_fnc_spectatorTarget;
showHUD [true, true, true, true, true, true, true, true, true, true, true];
addMissionEventHandler ["Draw3D", SPEC_fnc_spectatorDraw3d];

0 spawn {
    // slow loop
    while { WL_IsSpectator } do {
        {
            private _owner = _x getVariable ["BIS_WL_owner", independent];
            [_x, _owner] call WL2_fnc_sectorMarkerUpdate;
        } forEach BIS_WL_allSectors;

        "BIS_WL_targetEnemy" setMarkerPosLocal getPosASL WL_TARGET_ENEMY;
        "BIS_WL_targetEnemy" setMarkerAlphaLocal 1;
        "BIS_WL_targetEnemy" setMarkerDirLocal 45;
        "BIS_WL_targetFriendly" setMarkerPosLocal getPosASL WL_TARGET_FRIENDLY;
        "BIS_WL_targetFriendly" setMarkerAlphaLocal 1;
        uiSleep 5;
    };
};

0 spawn {
    private _spectatorInfo = uiNamespace getVariable ["RscWLSpectatorInfo", displayNull];
    if (isNull _spectatorInfo) then {
        "SpectatorInfo" cutRsc ["RscWLSpectatorInfo", "PLAIN", -1, true, true];
        _spectatorInfo = uiNamespace getVariable ["RscWLSpectatorInfo", displayNull];
    };
    private _spectatorInfoText = _spectatorInfo displayCtrl 101;
    private _spectatorControlsInfo = _spectatorInfo displayCtrl 102;
    private _spectatorTarget = _spectatorInfo displayCtrl 103;
    private _spectatorMode = _spectatorInfo displayCtrl 104;
    private _spectatorSpeed = _spectatorInfo displayCtrl 105;
    private _spectatorZoom = _spectatorInfo displayCtrl 106;
    private _spectatorTime = _spectatorInfo displayCtrl 107;

    _spectatorTarget ctrlSetStructuredText parseText "<t shadow='2'>Target: Free Camera</t>";
    _spectatorMode ctrlSetStructuredText parseText "<t shadow='2'>Mode: Bird Eye</t>";
    _spectatorSpeed ctrlSetStructuredText parseText "<t shadow='2'>Speed: 5 m/s</t>";
    _spectatorZoom ctrlSetStructuredText parseText "<t shadow='2'>Orbit: 1 m</t>";
    _spectatorTime ctrlSetStructuredText parseText "<t shadow='2'>Time: 00:00:00</t>";

    while { WL_IsSpectator } do {
        uiSleep 0.2;
        private _target = uiNamespace getVariable ["SPEC_CameraTarget", objNull];

        private _showControlsInfo = uiNamespace getVariable ["SPEC_ShowControlsInfo", true];
        if (_showControlsInfo) then {
            private _spectatorParams = if (isNull _target) then {
                [
                    ["Move forward", "cameraMoveForward"],
                    ["Move backward", "cameraMoveBackward"],
                    ["Move left", "cameraMoveLeft"],
                    ["Move right", "cameraMoveRight"],
                    ["Move up", "cameraMoveUp"],
                    ["Move down", "cameraMoveDown"],
                    ["Increase speed", "prevAction"],
                    ["Decrease speed", "nextAction"],
                    ["Select target", "lockTarget"]
                ];
            } else {
                [
                    ["Zoom in", "prevAction"],
                    ["Zoom out", "nextAction"],
                    ["Cycle target camera view", "personView"],
                    ["Unselect target", "lockTarget"],
                    ["Select projectile", "MoveUp"]
                ];
            };
            private _commonControls = [
                ["Target menu", "nextWeapon"],
                ["Show this help", "ListLeftVehicleDisplay"],
                ["Target details", "ListRightVehicleDisplay"],
                ["Vision mode", "nightVision"],
                ["HMD settings", "binocular"],
                ["Map", "showMap"],
                ["Deafen voice", "getOver"],
                ["Hide interface", "SelectGroupUnit1"],
                ["Settings menu", "compass"]
            ];
            _spectatorParams append _commonControls;

            private _controlNamesText = "";
            {
                private _actionName = _x select 0;
                private _actionKey = _x select 1;

                private _actionKeyText = (actionKeysNames _actionKey) regexReplace ["""", ""];
                _actionKeyText = toUpper _actionKeyText;
                if (_actionKeyText == "") then {
                    _actionKeyText = _actionKey;
                };
                private _lineText = format ["<t align='left'>%1</t><t align='right'>%2</t><br/>", _actionName, _actionKeyText];
                _controlNamesText = _controlNamesText + _lineText;
            } forEach _spectatorParams;
            _spectatorControlsInfo ctrlSetStructuredText parseText format ["<t shadow='2'>%1</t>", _controlNamesText];
        } else {
            _spectatorControlsInfo ctrlSetStructuredText parseText "";
        };

        private _timeRemaining = [(estimatedEndServerTime - serverTime) max 0, "HH:MM:SS"] call BIS_fnc_secondsToString;
        _spectatorTime ctrlSetStructuredText parseText format ["<t shadow='2'>Time: %1</t>", _timeRemaining];

        private _showTargetInfo = uiNamespace getVariable ["SPEC_ShowTargetInfo", true];
        if (!_showTargetInfo) then {
            _spectatorInfoText ctrlSetStructuredText parseText "";

            _spectatorTarget ctrlShow false;
            _spectatorMode ctrlShow false;
            _spectatorSpeed ctrlShow false;
            _spectatorZoom ctrlShow false;
            _spectatorTime ctrlShow false;
            continue;
        };

        if (isNull _target) then {
            _spectatorInfoText ctrlSetStructuredText parseText "";
            continue;
        };

        private _typeName = uiNamespace getVariable ["SPEC_CameraTargetName", "Unknown"];

        private _playerOwnerUid = _target getVariable ["BIS_WL_ownerAsset", "123"];
        private _playerOwner = if (_playerOwnerUid != "123") then {
            private _ownerPlayer = [_playerOwnerUid] call BIS_fnc_getUnitByUid;
            if (!isNull _ownerPlayer) then {
                private _fundsClient = missionNamespace getVariable ["fundsDatabaseClients", createHashMap];
                private _playerFunds = _fundsClient getOrDefault [getPlayerUID _ownerPlayer, 0];
                format ["Owner: %1 ($%2)", name _ownerPlayer, _playerFunds];
            } else {
                "";
            };
        } else {
            "";
        };

        private _targetVehicle = vehicle _target;

        private _targetPosition = _targetVehicle modelToWorld [0, 0, 0];
        private _currentWeapon = currentWeapon _targetVehicle;
        private _currentWeaponType = getText (configfile >> "CfgWeapons" >> _currentWeapon >> "displayName");
        if (_currentWeaponType != "") then {
            _currentWeaponType = format ["Weapon: %1", _currentWeaponType];
        };
        private _currentMagazine = currentMagazine _targetVehicle;
        private _currentMagazineType = [_currentMagazine] call WL2_fnc_getMagazineName;
        if (_currentMagazineType != "") then {
            _currentMagazineType = format ["Magazine: %1", _currentMagazineType];
        };

		private _rearmCooldown = _targetVehicle getVariable ["BIS_WL_nextRearm", -9999];

        private _rearmTimer = if (_rearmCooldown == -9999) then {
            "";
        } else {
            _rearmCooldown = (_rearmCooldown - serverTime) max 0;
            if (_rearmCooldown > 0) then {
                format ["Rearm: %1", [_rearmCooldown, "MM:SS"] call BIS_fnc_secondsToString];
            } else {
                "Rearm: Ready";
            };
        };

        private _repairCooldown = _targetVehicle getVariable ["WL2_nextRepair", -9999];
        private _repairTimer = if (_repairCooldown == -9999) then {
            "";
        } else {
            _repairCooldown = (_repairCooldown - serverTime) max 0;
            if (_repairCooldown > 0) then {
                format ["Repair: %1", [_repairCooldown, "MM:SS"] call BIS_fnc_secondsToString];
            } else {
                "Repair: Ready";
            };
        };

        private _apsAmmo = _targetVehicle getVariable ["apsAmmo", -1];
        private _apsInfo = if (_apsAmmo >= 0) then {
            format ["APS: %1", _apsAmmo];
        } else {
            "";
        };

        private _maxDemolitionHealth = _targetVehicle getVariable ["WL2_demolitionMaxHealth", 0];
        private _demoHealth = if (_maxDemolitionHealth > 0) then {
            private _currentDemolitionHealth = _targetVehicle getVariable ["WL2_demolitionHealth", 0];
            format ["Demolition: %1/%2", _currentDemolitionHealth, _maxDemolitionHealth];
        } else {
            "";
        };

        private _targetInfo = [
            _typeName,
            format ["Position: [%1, %2]", (_targetPosition # 0 / 100) toFixed 2, (_targetPosition # 1 / 100) toFixed 2],
            format ["Altitude (AGL): %1 M", round (_targetPosition # 2)],
            format ["Health: %1%%", ((1 - damage _target) * 100) toFixed 1],
            _demoHealth,
            format ["Speed: %1 KPH", (speed _targetVehicle) toFixed 1],
            _currentWeaponType,
            _currentMagazineType,
            _rearmTimer,
            _repairTimer,
            _apsInfo,
            _playerOwner
        ];

        private _captureDetails = _targetVehicle getVariable ["WL_captureDetails", []];
        if (count _captureDetails > 0) then {
            private _sectorOwner = _targetVehicle getVariable ["BIS_WL_owner", independent];

            private _captureDetailsArray = _captureDetails apply {
                _x params ["_side", "_score", "_multiplier"];
                if (_side == independent) then {
                    private _reserves = _targetVehicle getVariable ["WL2_sectorPop", 0];
                    private _reserveText = if (_reserves > 0) then { _reserves } else { "depleted" };
                    if (_sectorOwner != independent) then { "" } else {
                        format ["%1 (%2x): %3 (Reserves: %4)", _side, _multiplier toFixed 1, _score toFixed 0, _reserveText]
                    };
                } else {
                    if (_score < 1) then { "" } else {
                        format ["%1 (%2x): %3", _side, _multiplier toFixed 1, _score toFixed 0],
                    };
                };
            };
            _targetInfo append _captureDetailsArray;
        };

        _targetInfo = _targetInfo select {
            _x != "";
        };
        _targetInfo = format ["<t shadow='2'>%1</t>", _targetInfo joinString "<br/>"];
        _spectatorInfoText ctrlSetStructuredText parseText _targetInfo;

        _spectatorTarget ctrlShow true;
        _spectatorMode ctrlShow true;
        _spectatorSpeed ctrlShow true;
        _spectatorZoom ctrlShow true;
        _spectatorTime ctrlShow true;
    };
};