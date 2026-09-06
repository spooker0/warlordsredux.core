#include "includes.inc"
params ["_camera", "_deltaTime"];

private _moveLeft = (uiNamespace getVariable ["SPEC_CameraMoveRight", 0]) - (uiNamespace getVariable ["SPEC_CameraMoveLeft", 0]);
private _moveForward = (uiNamespace getVariable ["SPEC_CameraMoveForward", 0]) - (uiNamespace getVariable ["SPEC_CameraMoveBackward", 0]);
private _moveUp = (uiNamespace getVariable ["SPEC_CameraMoveUp", 0]) - (uiNamespace getVariable ["SPEC_CameraMoveDown", 0]);

private _speedCurve = [5, 10, 20, 40, 80, 160, 320, 640, 1280, 2560, 5120];

private _freeCamSpeed = uiNamespace getVariable ["SPEC_FreecamSpeed", 2];
private _mouseWheelUp = inputAction "prevAction";
private _mouseWheelDown = inputAction "nextAction";
if (_mouseWheelUp != 0) then {
    private _scoreboardScrolled = [-1] call WL2_fnc_scoreboardScroll;
    if (_scoreboardScrolled) then {
        _mouseWheelUp = 0;
    } else {
        _freeCamSpeed = _freeCamSpeed + 1;
    };
};
if (_mouseWheelDown != 0) then {
    private _scoreboardScrolled = [1] call WL2_fnc_scoreboardScroll;
    if (_scoreboardScrolled) then {
        _mouseWheelDown = 0;
    } else {
        _freeCamSpeed = _freeCamSpeed - 1;
    };
};
_freeCamSpeed = _freeCamSpeed max 0 min (count _speedCurve - 1);
uiNamespace setVariable ["SPEC_FreecamSpeed", _freeCamSpeed];

private _speed = _speedCurve select _freeCamSpeed;

if (_mouseWheelUp != 0 || _mouseWheelDown != 0) then {
    private _spectatorInfo = uiNamespace getVariable ["RscWLSpectatorInfo", displayNull];
    private _spectatorSpeed = _spectatorInfo displayCtrl 105;
    _spectatorSpeed ctrlSetStructuredText parseText format ["<t shadow='2'>Speed: %1 m/s</t>", _speed];
};

private _newPosition = _camera modelToWorld [
    _moveLeft * _speed * _deltaTime,
    _moveForward * _speed * _deltaTime,
    _moveUp * _speed * _deltaTime
];
private _newPosATL = ASLtoATL (AGLtoASL _newPosition);
_newPosATL set [2, _newPosATL # 2 max 1];
_camera setPosATL _newPosATL;

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