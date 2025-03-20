#include "constants.inc"

params ["_projectile", "_unit"];

private _originalTarget = missileTarget _projectile;
private _dangerZone = if (_originalTarget isKindOf "Helicopter") then {
    3000;
} else {
    4000;
};
private _inDangerZone = (_projectile distance _originalTarget) < _dangerZone;

[_projectile] spawn {
    params ["_projectile"];
    private _startTime = time;
    private _isLOAL = getNumber (configfile >> "CfgAmmo" >> typeOf _projectile >> "autoSeekTarget") == 1;

    while { alive _projectile } do {
        sleep 7;

        private _inFrontAngle = [getPosASL _projectile, getDir _projectile, 180, getPosASL (missileTarget _projectile)] call BIS_fnc_inAngleSector;
        if (!_inFrontAngle) then {
            triggerAmmo _projectile;
        };

        // Ghost missile relocking check.
        if (_isLOAL && !(alive missileTarget _projectile)) exitWith {
            triggerAmmo _projectile;
        };
        if (time > (_startTime + WL_SAM_TIMEOUT)) exitWith {
            triggerAmmo _projectile;
        };
    };
};

[_projectile, _unit, _inDangerZone, _originalTarget] spawn {
    params ["_projectile", "_unit", "_inDangerZone", "_originalTarget"];
    sleep 1;
    while { alive _projectile } do {
        sleep 0.2;
        // if (_inDangerZone) then {
        //     _projectile setMissileTarget [_originalTarget, true];
        // };

        private _missileTarget = missileTarget _projectile;
        private _missileTargetSide = _missileTarget getVariable ["BIS_WL_ownerAssetSide", side _missileTarget];
        private _projectileSide = side (group _unit);
        if (_missileTargetSide == _projectileSide) exitWith {
            triggerAmmo _projectile;
        };
    };
};

private _maxAcceleration = (getNumber (configfile >> "CfgAmmo" >> typeOf _projectile >> "thrust")) / 10.0 * WL_SAM_ACCELERATION_FACTOR;
private _maxSpeed = getNumber (configfile >> "CfgAmmo" >> typeOf _projectile >> "maxSpeed") * WL_SAM_MAX_SPEED_FACTOR;

private _terrainTest = 4000;
while { alive _projectile } do {
    private _currentVector = velocityModelSpace _projectile;
    private _currentSpeed = (_currentVector # 1) + ((_maxAcceleration * 0.01) min _maxSpeed);
    private _newVector = [
        0,
        _currentSpeed,
        0
    ];
    _projectile setVelocityModelSpace _newVector;

    private _angularVector = angularVelocityModelSpace _projectile;
    private _start = getPosASL _projectile;
    private _end = _projectile modelToWorldWorld [0, _terrainTest, -100];
    private _intersectPosition = terrainIntersectAtASL [_start, _end];
    private _target = missileTarget _projectile;
    private _targetHeightATL = if !(isNull _target) then {
        (getPosATL _target # 2) min (getPosASL _projectile # 2);
    } else {
        100;
    };
    private _projectileHeightATL = (getPosATL _projectile # 2) min (getPosASL _projectile # 2);
    private _distanceToGround = _intersectPosition distance _start;
    _projectileHeightATL = _projectileHeightATL min _distanceToGround;
    private _belowTargetATL = _projectileHeightATL < _targetHeightATL;
    if (!(_intersectPosition isEqualTo [0, 0, 0]) && _belowTargetATL) then {
        _projectile setAngularVelocityModelSpace [-30 * (_terrainTest -_distanceToGround) / _terrainTest, _angularVector # 1, _angularVector # 2];
    } else {
        private _accelerationFactor = if (_inDangerZone) then {
            5 * WL_SAM_ANGULAR_ACCELERATION;
        } else {
            WL_SAM_ANGULAR_ACCELERATION;
        };
        private _newAngularVector = _angularVector vectorMultiply _accelerationFactor;
        _projectile setAngularVelocityModelSpace _newAngularVector;
    };

    private _vectorUp = vectorUp _projectile;
    _vectorUp set [0, 0];
    _vectorUp set [1, 0];
    _projectile setVectorDirAndUp [vectorDir _projectile, _vectorUp];

    sleep 0.001;
};
