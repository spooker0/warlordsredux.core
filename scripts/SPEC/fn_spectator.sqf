#include "includes.inc"

if (WL_IsSpectator) exitWith {};
WL_IsSpectator = true;

// hide spectator on land
// player setPosASL [2304.97, 9243.11, 11.5];
// player allowDamage false;
// [player] remoteExec ["WL2_fnc_hideObjectOnAll", 2];

private _missionSpectators = missionNamespace getVariable ["WL2_spectators", []];
_missionSpectators pushBackUnique player;
_missionSpectators = _missionSpectators select { !isNull _x };
missionNamespace setVariable ["WL2_spectators", _missionSpectators, true];

setPlayerRespawnTime 10000000;
forceRespawn player;
[player] remoteExec ["WL2_fnc_hideObjectOnAll", 2];

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

private _display = uiNamespace getVariable ["RscWLSpectatorMenu", displayNull];
if (isNull _display) then {
	"spectator" cutRsc ["RscWLSpectatorMenu", "PLAIN", -1, true, true];
	_display = uiNamespace getVariable ["RscWLSpectatorMenu", displayNull];
};
private _texture = _display displayCtrl 5502;
// _texture ctrlWebBrowserAction ["OpenDevConsole"];

_texture ctrlAddEventHandler ["PageLoaded", {
    params ["_texture"];
    private _freeCamSpeed = uiNamespace getVariable ["SPEC_FreecamSpeed", 2];
    _texture ctrlWebBrowserAction ["ExecJS", format ["updateSpeedLevel(%1);", _freeCamSpeed]];
}];

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
        [_camera, _deltaTime] call SPEC_fnc_spectatorFree;
    } else {
        [_camera, _deltaTime, _currentTarget] call SPEC_fnc_spectator3P;
    };

    uiNamespace setVariable ["SPEC_LastFrameTime", serverTime];
}];

private _mainDisplay = findDisplay 46;
[46] spawn GFE_fnc_earplugs;
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
        _targetCamMode = (_targetCamMode + 1) mod 4;
        uiNamespace setVariable ["SPEC_TargetCameraMode", _targetCamMode];

        private _display = uiNamespace getVariable ["RscWLSpectatorMenu", displayNull];
        private _texture = _display displayCtrl 5502;
        _texture ctrlWebBrowserAction ["ExecJS", format ["updateTargetMode(%1);", _targetCamMode]];

        true;
    };

    if (_key in actionKeys "nextWeapon") exitWith {
        0 spawn SPEC_fnc_spectatorMenu;
    };

    if (_key in actionKeys "lockTarget") exitWith {
        private _currentTarget = uiNamespace getVariable ["SPEC_CameraTarget", objNull];
        if (!isNull _currentTarget) exitWith {
            [objNull] call SPEC_fnc_spectatorSelectTarget;
        };

        private _fromPos = getPosASL cameraOn;
        private _toPos = ((cameraOn screenToWorldDirection [0.5, 0.5]) vectorMultiply 1000) vectorAdd _fromPos;

        private _intersects = lineIntersectsWith [_fromPos, _toPos, objNull, objNull, true];
        private _newTarget = if (count _intersects > 0) then {
            _intersects select (count _intersects - 1);
        } else {
            private _spot = screenToWorld [0.5, 0.5];
            private _objects = nearestObjects [_spot, ["AllVehicles", "Man"], 10];
            if (count _objects > 0) then {
                _objects select 0;
            } else {
                objNull;
            };
        };

        if !(isNull _newTarget) then {
            [_newTarget] call SPEC_fnc_spectatorSelectTarget;
        };
    };
}];

_mainDisplay displayAddEventHandler ["KeyUp", {
    params ["_displayOrControl", "_key", "_shift", "_ctrl", "_alt"];

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
        private _display = uiNamespace getVariable ["RscWLHmdSettingMenu", displayNull];
        if (isNull _display) then {
            0 spawn WL2_fnc_hmdSettings;
        } else {
            "hmd" cutText ["", "PLAIN"];
        };
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
                true setCamUseTI 2;
                setTIParameter ["OutputRangeStart", 0];
                setTIParameter ["OutputRangeWidth", 1];
                setTIParameter ["FilmGrain", 0];
                setTIParameter ["Blur", 0];
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
                _x setPlayerVoNVolume 0.1;
            } forEach allPlayers;
        };
        _vonMuted = !_vonMuted;
        uiNamespace setVariable ["SPEC_VoNMuted", _vonMuted];
    };

    if (_key in actionKeys "SelectGroupUnit1") exitWith {
        private _display = uiNamespace getVariable ["RscWLSpectatorMenu", displayNull];
        private _texture = _display displayCtrl 5502;
        if (ctrlShown _texture) then {
            _texture ctrlShow false;
        } else {
            _texture ctrlShow true;
        };
    };

    if (_key in actionKeys "compass") exitWith {
        call MENU_fnc_settingsMenuInit;
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
    while { WL_IsSpectator } do {
        uiSleep 0.2;
        private _target = uiNamespace getVariable ["SPEC_CameraTarget", objNull];
        private _display = uiNamespace getVariable ["RscWLSpectatorMenu", displayNull];
        private _texture = _display displayCtrl 5502;

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
                    ["Unselect target", "lockTarget"]
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
            private _controlKeysText = "";
            {
                private _actionName = _x select 0;
                private _actionKey = _x select 1;

                private _actionKeyText = (actionKeysNames _actionKey) regexReplace ["""", ""];
                _actionKeyText = toUpper _actionKeyText;
                if (_actionKeyText == "") then {
                    _actionKeyText = _actionKey;
                };
                _controlNamesText = format ["%1%2<br/>", _controlNamesText, _actionName];
                _controlKeysText = format ["%1[%2]<br/>", _controlKeysText, _actionKeyText];
            } forEach _spectatorParams;

            _texture ctrlWebBrowserAction ["ExecJS", format ["setControlsInfo(['%1', '%2']);", _controlNamesText, _controlKeysText]];
        } else {
            _texture ctrlWebBrowserAction ["ExecJS", "setControlsInfo(['','']);"];
        };

        private _showTargetInfo = uiNamespace getVariable ["SPEC_ShowTargetInfo", true];
        if (isNull _target || !_showTargetInfo) then {
            _texture ctrlWebBrowserAction ["ExecJS", "setTargetInfo(``);"];
            continue;
        };

        private _typeName = uiNamespace getVariable ["SPEC_CameraTargetName", "Unknown"];

        private _playerOwnerUid = _target getVariable ["BIS_WL_ownerAsset", "123"];
        private _playerOwner = if (_playerOwnerUid != "123") then {
            private _ownerPlayer = [_playerOwnerUid] call BIS_fnc_getUnitByUid;
            if (!isNull _ownerPlayer) then {
                format ["Owner: %1<br/>", name _ownerPlayer];
            } else {
                "";
            };
        } else {
            "";
        };

        private _targetPosition = getPosASL _target;
        private _currentWeapon = currentWeapon _target;
        private _currentWeaponType = getText (configfile >> "CfgWeapons" >> _currentWeapon >> "displayName");
        if (_currentWeaponType != "") then {
            _currentWeaponType = format ["Weapon: %1<br/>", _currentWeaponType];
        };
        private _currentMagazine = currentMagazine _target;
        private _currentMagazineType = [_currentMagazine] call WL2_fnc_getMagazineName;
        if (_currentMagazineType != "") then {
            _currentMagazineType = format ["Magazine: %1<br/>", _currentMagazineType];
        };

		private _rearmCooldown = _target getVariable ["BIS_WL_nextRearm", -9999];

        private _rearmTimer = if (_rearmCooldown == -9999) then {
            "";
        } else {
            _rearmCooldown = (_rearmCooldown - serverTime) max 0;
            if (_rearmCooldown > 0) then {
                format ["Rearm: %1<br/>", [_rearmCooldown, "MM:SS"] call BIS_fnc_secondsToString];
            } else {
                "Rearm: Ready<br/>";
            };
        };

        private _repairCooldown = _target getVariable ["WL2_nextRepair", -9999];
        private _repairTimer = if (_repairCooldown == -9999) then {
            "";
        } else {
            _repairCooldown = (_repairCooldown - serverTime) max 0;
            if (_repairCooldown > 0) then {
                format ["Repair: %1<br/>", [_repairCooldown, "MM:SS"] call BIS_fnc_secondsToString];
            } else {
                "Repair: Ready<br/>";
            };
        };

        private _apsAmmo = _target getVariable ["apsAmmo", -1];
        private _apsInfo = if (_apsAmmo >= 0) then {
            format ["APS: %1<br/>", _apsAmmo];
        } else {
            "";
        };

        private _targetInfo = format [
            "%1<br/>Position: [%2, %3]<br/>Altitude (ASL): %4 M<br/>Health: %5%%<br/>Speed: %6 KPH<br/>%7%8%9%10%11%12",
            _typeName,
            (_targetPosition # 0 / 100) toFixed 2,
            (_targetPosition # 1 / 100) toFixed 2,
            round (_targetPosition # 2),
            ((1 - damage _target) * 100) toFixed 1,
            (speed _target) toFixed 1,
            _currentWeaponType,
            _currentMagazineType,
            _rearmTimer,
            _repairTimer,
            _apsInfo,
            _playerOwner
        ];
        private _targetInfoArray = toArray _targetInfo;
        {
            if (_x == 160) then {
                _targetInfoArray set [_forEachIndex, 32];
            };
        } forEach _targetInfoArray;
        _targetInfo = toString _targetInfoArray;

        _texture ctrlWebBrowserAction ["ExecJS", format ["setTargetInfo('%1');", _targetInfo]];
    };
};