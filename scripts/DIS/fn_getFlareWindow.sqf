#include "includes.inc"
params ["_target", "_projectile"];

if (!alive _target || !alive _projectile) exitWith {
    [];
};

private _missileDefeated = _projectile getVariable ["DIS_missileDefeated", false];
if (_missileDefeated) exitWith {
    [];
};

if (!isNull attachedTo _projectile) exitWith {
    [];
};

private _flareMin = _projectile getVariable ["DIS_flareMin", 0];
private _flareMax = _projectile getVariable ["DIS_flareMax", 0];
if (_flareMax <= _flareMin) exitWith {
    [];
};

private _incomingMissiles = _target getVariable ["WL_incomingMissiles", []];
if (!(_projectile in _incomingMissiles)) exitWith {
    [];
};

private _directionToTarget = (getPosASL _projectile) vectorFromTo (getPosASL _target);
private _approach = (vectorDir _projectile) vectorDotProduct _directionToTarget;

private _relativeVelocity = _projectile vectorWorldToModel (velocity _target);
private _perpendicularSpeed = abs (_relativeVelocity # 0);

private _targetMaxSpeed = _target getVariable ["WL2_maxSpeed", 500];

private _optimalRange = (_flareMin + _flareMax) / 2;
private _fullHalfWidth = (_flareMax - _flareMin) / 2;
private _halfWidth = linearConversion [0, _targetMaxSpeed / 2, _perpendicularSpeed, 100, _fullHalfWidth, true];
private _minimumRange = _optimalRange - _halfWidth;
private _maximumRange = _optimalRange + _halfWidth;
private _distance = _projectile distance _target;
private _inRange = _distance >= _minimumRange && _distance <= _maximumRange && _approach > 0;

[_minimumRange, _optimalRange, _maximumRange, _distance, _inRange];
