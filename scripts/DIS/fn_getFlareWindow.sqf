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
private _deltaBonus = _projectile getVariable ["DIS_flareDeltaBonus", 0];

private _minimumRange = if (_deltaBonus > 0) then {
    linearConversion [0, 1, _deltaBonus, _flareMin, _flareMax, true];
} else {
    linearConversion [0, _targetMaxSpeed / 2, _perpendicularSpeed, _flareMin, 0, true];
};

private _midpointRange = (_minimumRange + _flareMax) / 2;
private _distance = _projectile distance _target;
private _inRange = _minimumRange < _flareMax && _distance >= _minimumRange && _distance <= _flareMax && _approach > 0;

[_minimumRange, _midpointRange, _flareMax, _distance, _inRange];
