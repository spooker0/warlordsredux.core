#include "includes.inc"
WL_IsSpectator = true;
[SPEC_DISPLAY] spawn GFE_fnc_earplugs;

// hide spectator on land
// player setPosASL [2304.97, 9243.11, 11.5];
// player allowDamage false;
// [player] remoteExec ["WL2_fnc_hideObjectOnAll", 2];

setPlayerRespawnTime 10000000;
forceRespawn player;
0 spawn {
    uiSleep 3;
    (uiNamespace getVariable ["RscRespawnCounter", displayNull]) closeDisplay 1;
};

private _osdDisplay = uiNamespace getVariable ["RscTitleDisplayEmpty", displayNull];
_osdDisplay closeDisplay 0;

private _camera = "camera" camCreate (position player);
_camera camCommit 0;
_camera switchCamera "INTERNAL";

uiNamespace setVariable ["SPEC_Camera", _camera];

addMissionEventHandler ["EachFrame", {
    private _camera = uiNamespace getVariable ["SPEC_Camera", objNull];
    if (isNull _camera) exitWith {};

    private _currentTargetIndex = uiNamespace getVariable ["SPEC_CameraTargetIndex", -1];
    if (_currentTargetIndex != -1 && _currentTargetIndex < (count allUnits - 1)) exitWith {
        private _target = allUnits select _currentTargetIndex;
        switchCamera _target;
    };

    if (_currentTargetIndex == -1 && cameraView != "Internal") then {
        _camera switchCamera "Internal";
    };

    private _lastFrameTime = uiNamespace getVariable ["SPEC_LastFrameTime", serverTime];
    private _deltaTime = (serverTime - _lastFrameTime) min 1;

    private _moveLeft = (uiNamespace getVariable ["SPEC_CameraMoveRight", 0]) - (uiNamespace getVariable ["SPEC_CameraMoveLeft", 0]);
    private _moveForward = (uiNamespace getVariable ["SPEC_CameraMoveForward", 0]) - (uiNamespace getVariable ["SPEC_CameraMoveBackward", 0]);
    private _moveUp = (uiNamespace getVariable ["SPEC_CameraMoveUp", 0]) - (uiNamespace getVariable ["SPEC_CameraMoveDown", 0]);

    private _speed = 100;

    private _newPosition = _camera modelToWorldWorld [
        _moveLeft * _speed * _deltaTime,
        _moveForward * _speed * _deltaTime,
        _moveUp * _speed * _deltaTime
    ];
    _camera setPosASL _newPosition;

    private _rotateSpeed = 100;

    private _rotateLeft = inputAction "BuldMoveLeft" - inputAction "BuldMoveRight";
    private _rotateUp = inputAction "BuldMoveForward" - inputAction "BuldMoveBack";

    private _yaw = getDir _camera;
    private _dir = vectorDir _camera;
    private _pitch = (_dir select 2) atan2 (sqrt ((_dir select 0)^2 + (_dir select 1)^2));

    _yaw = _yaw - _rotateLeft * _deltaTime * _rotateSpeed;
    _pitch = (_pitch + _rotateUp * _deltaTime * _rotateSpeed) min (89) max (-89);

    private _cosPitch = cos _pitch;
    private _sinPitch = sin _pitch;
    private _cosYaw = cos _yaw;
    private _sinYaw = sin _yaw;

    private _forward = [
        _cosPitch * _sinYaw,
        _cosPitch * _cosYaw,
        _sinPitch
    ];
    private _right = _forward vectorCrossProduct [0, 0, 1];
    _right = vectorNormalized _right;

    private _up = _right vectorCrossProduct _forward;
    _up = vectorNormalized _up;

    _camera setVectorDirAndUp [_forward, _up];

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

    if (_key in actionKeys "BuldLeft") exitWith {
        private _currentTargetIndex = uiNamespace getVariable ["SPEC_CameraTargetIndex", -1];
        _currentTargetIndex = (_currentTargetIndex - 1) max -1;
        uiNamespace setVariable ["SPEC_CameraTargetIndex", _currentTargetIndex];

        if (_currentTargetIndex == -1) then {
            private _camera = uiNamespace getVariable ["SPEC_Camera", objNull];
            if (!isNull _camera) then {
                _camera switchCamera "Internal";
            };
        };
    };
    if (_key in actionKeys "BuldRight") exitWith {
        private _currentTargetIndex = uiNamespace getVariable ["SPEC_CameraTargetIndex", -1];
        _currentTargetIndex = _currentTargetIndex + 1;
        uiNamespace setVariable ["SPEC_CameraTargetIndex", _currentTargetIndex];
    };
}];

uiNamespace setVariable ["SPEC_CameraTargetIndex", -1];