#include "includes.inc"
params ["_camera", "_deltaTime", "_currentTarget"];

private _targetCamMode = uiNamespace getVariable ["SPEC_TargetCameraMode", 0];
if (_targetCamMode == 1) exitWith {
    _currentTarget switchCamera "Internal";
};
if (_targetCamMode == 2) exitWith {
    _currentTarget switchCamera "External";
};
if (_targetCamMode == 3) exitWith {
    _currentTarget switchCamera "Gunner";
};
_camera switchCamera "Internal";

private _rotateSpeed = 100;
private _rotateLeft = inputAction "BuldMoveLeft" - inputAction "BuldMoveRight";
private _rotateUp = inputAction "BuldMoveForward" - inputAction "BuldMoveBack";
private _zoomIn = inputAction "prevAction";
private _zoomOut = inputAction "nextAction";

private _radius = uiNamespace getVariable ["SPEC_3PRadius", 5];
private _yaw = uiNamespace getVariable ["SPEC_3PYaw", 0];
private _pitch = uiNamespace getVariable ["SPEC_3PPitch", 15];

_yaw = _yaw - _rotateLeft * _deltaTime * _rotateSpeed;
_pitch = (_pitch - _rotateUp * _deltaTime * _rotateSpeed) min 89 max -89;

private _zoomDelta = _zoomOut - _zoomIn;
private _targetIsLogic = _currentTarget isKindOf "Logic";
private _maxRadius = if (_targetIsLogic) then { 500 } else { 50 };
if (_radius >= 10) then {
    _zoomDelta = _zoomDelta * 5;
};
_radius = (_radius + _zoomDelta) max 1 min _maxRadius;

if (_zoomDelta != 0) then {
    private _display = uiNamespace getVariable ["RscWLSpectatorMenu", displayNull];
    private _texture = _display displayCtrl 5502;
    private _zoomLevel = linearConversion [1, _maxRadius, _radius, 0, 1];
    _texture ctrlWebBrowserAction ["ExecJS", format ["updateZoomLevel(%1);", _zoomLevel]];
};

private _cosP = cos _pitch;
private _sinP = sin _pitch;
private _cosY = cos _yaw;
private _sinY = sin _yaw;

private _offset = [
    _radius * _cosP * _sinY,
    _radius * _cosP * _cosY,
    _radius * _sinP
];

private _tPos = getPosASL _currentTarget;
private _camPos = _tPos vectorAdd _offset;

private _forward = vectorNormalized (_tPos vectorDiff _camPos);
private _right = _forward vectorCrossProduct [0,0,1];
if ((vectorMagnitude _right) < 0.0001) then { _right = [1,0,0]; };
_right = vectorNormalized _right;
private _up = vectorNormalized (_right vectorCrossProduct _forward);

_camera setVectorDirAndUp [_forward, _up];
_camera setPosASL _camPos;

uiNamespace setVariable ["SPEC_3PYaw", _yaw];
uiNamespace setVariable ["SPEC_3PPitch", _pitch];
uiNamespace setVariable ["SPEC_3PRadius", _radius];