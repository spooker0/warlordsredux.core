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
private _zoomIn = if (inputAction "prevAction" > 0) then { 1 } else { 0 };
private _zoomOut = if (inputAction "nextAction" > 0) then { 1 } else { 0 };

if (_zoomIn != 0) then {
    private _scoreboardScrolled = [-1] call WL2_fnc_scoreboardScroll;
    if (_scoreboardScrolled) then {
        _zoomIn = 0;
    };
};
if (_zoomOut != 0) then {
    private _scoreboardScrolled = [1] call WL2_fnc_scoreboardScroll;
    if (_scoreboardScrolled) then {
        _zoomOut = 0;
    };
};

private _radius = uiNamespace getVariable ["SPEC_3PRadius", 5];
private _yaw = uiNamespace getVariable ["SPEC_3PYaw", 0];
private _pitch = uiNamespace getVariable ["SPEC_3PPitch", 15];

_yaw = _yaw - _rotateLeft * _deltaTime * _rotateSpeed;
_pitch = (_pitch - _rotateUp * _deltaTime * _rotateSpeed) min 89 max -89;

private _zoomDelta = _zoomOut - _zoomIn;
private _targetIsLogic = _currentTarget getVariable ["WL2_name", ""] != "";
private _maxRadius = if (_targetIsLogic) then { 250 } else { 50 };

private _resetRadius = uiNamespace getVariable ["SPEC_resetRadius", false];
if (_resetRadius) then {
    _radius = _maxRadius;
    uiNamespace setVariable ["SPEC_resetRadius", false];
};

if ((_radius + _zoomDelta) >= 10) then {
    _zoomDelta = _zoomDelta * 5;
};
_radius = (_radius + _zoomDelta) max 1 min _maxRadius;

if (_zoomDelta != 0) then {
    private _spectatorInfo = uiNamespace getVariable ["RscWLSpectatorInfo", displayNull];
    private _spectatorZoom = _spectatorInfo displayCtrl 106;
    _spectatorZoom ctrlSetStructuredText parseText format ["<t shadow='2'>Orbit: %1 m</t>", round _radius];
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

private _tPos = getPosASLVisual _currentTarget;
private _camPos = _tPos vectorAdd _offset;

private _forward = vectorNormalized (_tPos vectorDiff _camPos);
private _right = _forward vectorCrossProduct [0,0,1];
if ((vectorMagnitude _right) < 0.0001) then { _right = [1, 0, 0]; };
_right = vectorNormalized _right;
private _up = vectorNormalized (_right vectorCrossProduct _forward);

_camera setVectorDirAndUp [_forward, _up];
_camera setPosASL _camPos;

uiNamespace setVariable ["SPEC_3PYaw", _yaw];
uiNamespace setVariable ["SPEC_3PPitch", _pitch];
uiNamespace setVariable ["SPEC_3PRadius", _radius];