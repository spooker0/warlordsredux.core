#include "includes.inc"
params ["_projectile", "_target", "_boostAltitude"];

if (isNull _target) exitWith {};

sleep 0.5;

_projectile setVariable ["WL2_missileStateOverride", "BOOST", true];
_projectile setVariable ["APS_missileState", "BOOST", true];

private _posAbove = _projectile modelToWorldWorld [0, 100, 2000];
private _firstStageVectorDirAndUp = [getPosASL _projectile, _posAbove] call BIS_fnc_findLookAt;

private _firstStageTime = serverTime;
while { alive _projectile && alive _target && serverTime < _firstStageTime + 1 } do {
    private _elapsedTime = serverTime - _firstStageTime;
    private _actualVectorDir = vectorLinearConversion [0, 1, _elapsedTime, vectorDir _projectile, _firstStageVectorDirAndUp # 0, true];
    private _actualVectorUp = vectorLinearConversion [0, 1, _elapsedTime, vectorUp _projectile, _firstStageVectorDirAndUp # 1, true];
    _projectile setVectorDirAndUp [_actualVectorDir, _actualVectorUp];
    sleep 0.01;
};
_projectile setVectorDirAndUp _firstStageVectorDirAndUp;

private _altitude = getPosASL _projectile # 2;
while { _altitude < _boostAltitude } do {
    private _boostSpeed = linearConversion [0, 2000, _altitude, 40, 3000, true];
    _projectile setVelocityModelSpace [0, _boostSpeed, 0];
    _projectile setVectorDirAndUp _firstStageVectorDirAndUp;

    _altitude = getPosASL _projectile # 2;
    sleep 0.1;
};

private _targetVectorDirAndUp = [getPosASL _projectile, getPosASL _target] call BIS_fnc_findLookAt;

private _startTime = serverTime;
while { alive _projectile && alive _target && serverTime < _startTime + 1 } do {
    private _elapsedTime = serverTime - _startTime;
    private _actualVectorDir = vectorLinearConversion [0, 1, _elapsedTime, vectorDir _projectile, _targetVectorDirAndUp # 0, true];
    private _actualVectorUp = vectorLinearConversion [0, 1, _elapsedTime, vectorUp _projectile, _targetVectorDirAndUp # 1, true];
    _projectile setVectorDirAndUp [_actualVectorDir, _actualVectorUp];
    sleep 0.01;
};

_projectile setVariable ["WL2_missileStateOverride", "", true];
_projectile setMissileTarget [_target, true];