#include "includes.inc"
params ["_projection", "_startDirection", ["_endDirection", []], ["_allowOffscreen", false]];

// Inputs are world-space directions. An omitted end direction projects a point.
_projection params ["_cameraASL", "_frustumPlanes", ["_cameraProjection", []]];

private _startMagnitudeSquared = vectorMagnitudeSqr _startDirection;
if (_startMagnitudeSquared < 1e-12) exitWith { [] };

_startDirection = vectorNormalized _startDirection;

private _projectDirection = {
    params ["_direction"];

    // A camera-centred ray has the same projection at any positive distance.
    // Add in ASL; only convert the final position to the AGL worldToScreen needs.
    private _normalizedDirection = vectorNormalized _direction;
    private _projectionOffset = _normalizedDirection vectorMultiply 1000;
    private _projectionASL = _cameraASL vectorAdd _projectionOffset;
    private _projectionAGL = ASLToAGL _projectionASL;
    private _screenPoint = worldToScreen _projectionAGL;

    _screenPoint
};

if (count _endDirection == 0) exitWith {
    // Guidance needs the projected X even when the desired point is offscreen.
    // Use the calibrated camera projection without rejecting its side planes.
    if (_allowOffscreen) exitWith {
        if (count _cameraProjection != 5) exitWith { [] };

        _cameraProjection params ["_cameraRight", "_cameraUp", "_cameraForward", "_screenCenter", "_projectionScale"];
        _screenCenter params ["_centerX", "_centerY"];
        _projectionScale params ["_horizontalScale", "_verticalScale"];

        private _forwardDistance = _startDirection vectorDotProduct _cameraForward;
        if (_forwardDistance <= 1e-5) exitWith { [] };

        private _rightDistance = _startDirection vectorDotProduct _cameraRight;
        private _upDistance = _startDirection vectorDotProduct _cameraUp;
        private _screenX = _centerX + _horizontalScale * _rightDistance / _forwardDistance;
        private _screenY = _centerY - _verticalScale * _upDistance / _forwardDistance;

        [_screenX, _screenY]
    };

    private _outsidePlaneIndex = _frustumPlanes findIf {
        _x params ["_planeNormal", "_planeOffset"];
        private _planeDistance = _startDirection vectorDotProduct _planeNormal;

        _planeDistance < _planeOffset
    };
    if (_outsidePlaneIndex >= 0) exitWith { [] };

    [_startDirection] call _projectDirection
};

private _endMagnitudeSquared = vectorMagnitudeSqr _endDirection;
if (_endMagnitudeSquared < 1e-12) exitWith { [] };

_endDirection = vectorNormalized _endDirection;

private _enterFraction = 0;
private _leaveFraction = 1;
private _visible = true;
{
    _x params ["_planeNormal", "_planeOffset"];

    private _startDistance = (_startDirection vectorDotProduct _planeNormal) - _planeOffset;
    private _endDistance = (_endDirection vectorDotProduct _planeNormal) - _planeOffset;
    if (_startDistance < 0 && _endDistance < 0) exitWith {
        _visible = false;
    };

    if (_startDistance < 0 || _endDistance < 0) then {
        private _intersectionFraction = _startDistance / (_startDistance - _endDistance);
        if (_startDistance < 0) then {
            _enterFraction = _enterFraction max _intersectionFraction;
        } else {
            _leaveFraction = _leaveFraction min _intersectionFraction;
        };
    };

    if (_enterFraction > _leaveFraction) exitWith {
        _visible = false;
    };
} forEach _frustumPlanes;
if (!_visible || _enterFraction >= _leaveFraction) exitWith { [] };

private _directionDelta = _endDirection vectorDiff _startDirection;
private _clippedStartDirection = _startDirection vectorAdd (_directionDelta vectorMultiply _enterFraction);
private _clippedEndDirection = _startDirection vectorAdd (_directionDelta vectorMultiply _leaveFraction);
private _startScreenPoint = [_clippedStartDirection] call _projectDirection;
private _endScreenPoint = [_clippedEndDirection] call _projectDirection;
if (count _startScreenPoint != 2 || count _endScreenPoint != 2) exitWith { [] };

[_startScreenPoint, _endScreenPoint]
