#include "constants.inc"

params ["_projectile", "_unit"];

[_projectile] spawn {
    params ["_projectile"];
    private _startTime = time;
    private _isLOAL = getNumber (configfile >> "CfgAmmo" >> typeOf _projectile >> "autoSeekTarget") == 1;

    while { alive _projectile } do {
        sleep 7;

        // Ghost missile relocking check.
        if (_isLOAL && !(alive missileTarget _projectile)) exitWith {
            triggerAmmo _projectile;
        };
        if (time > (_startTime + WL_SAM_TIMEOUT)) exitWith {
            triggerAmmo _projectile;
        };
    };
};

[_projectile, _unit] spawn {
    params ["_projectile", "_unit"];
    sleep 1;
    private _originalTarget = missileTarget _projectile;
    private _thrust = getNumber (configfile >> "CfgAmmo" >> (typeOf _projectile) >> "thrust");
    private _dangerZone = 3000 + _thrust * 5;
    private _inDangerZone = (_projectile distance _originalTarget) < _dangerZone;
    while { alive _projectile } do {
        sleep 0.2;
        if (_inDangerZone) then {
            systemChat "Enemy target in death zone.";
            _projectile setMissileTarget [_originalTarget, true];
        };

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
    private _end = _projectile modelToWorldWorld [0, 2000, -100];
    private _intersectPosition = terrainIntersectAtASL [_start, _end];
    private _target = missileTarget _projectile;
    private _targetHeightATL = if !(isNull _target) then {
        (getPosATL _target # 2) min (getPosASL _projectile # 2);
    } else {
        100;
    };
    private _projectileHeightATL = (getPosATL _projectile # 2) min (getPosASL _projectile # 2);
    private _belowTargetATL = _projectileHeightATL < _targetHeightATL;
    if (!(_intersectPosition isEqualTo [0, 0, 0]) && _belowTargetATL) then {
        private _distanceToGround = _intersectPosition distance _start;
        _projectile setAngularVelocityModelSpace [-20 * (2000 -_distanceToGround) / 2000, _angularVector # 1, _angularVector # 2];
    } else {
        private _newAngularVector = _angularVector vectorMultiply WL_SAM_ANGULAR_ACCELERATION;
        _projectile setAngularVelocityModelSpace _newAngularVector;
    };

    sleep 0.001;
};
