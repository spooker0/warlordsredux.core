#include "constants.inc"

params ["_projectile", "_unit"];

private _originalTarget = missileTarget _projectile;
private _originalPosition = getPosASL _unit;
[_projectile, _originalTarget, _unit] spawn {
    params ["_projectile", "_originalTarget", "_unit"];
    private _startTime = time;
    private _isLOAL = getNumber (configfile >> "CfgAmmo" >> typeOf _projectile >> "autoSeekTarget") == 1;

    while { alive _projectile } do {
        sleep 0.1;

        private _projectilePosition = getPosASL _projectile;
        private _targetPosition = getPosASL _originalTarget;
        if !(isNull _originalTarget) then {
            private _inFrontAngle = [_projectilePosition, getDir _projectile, 180, _targetPosition] call WL2_fnc_inAngleCheck;
            if (!_inFrontAngle) then {
                triggerAmmo _projectile;
            };
        };

        // Notching mechanic
        private _notchResult = [_originalTarget, _unit, _projectile] call DIS_fnc_getNotchResult;
        if (_notchResult == 4) then {
            _projectile setVariable ["DIS_notched", true];
        } else {
            // If not already notched and not notching
            if (_projectile getVariable ["DIS_notched", false]) then {
                _projectile setMissileTarget [_originalTarget, true];
            };
        };

        private _currentMissileTarget = missileTarget _projectile;
        // Ghost missile relocking check.
        if (_isLOAL && alive _currentMissileTarget && _currentMissileTarget != _originalTarget) then {
            triggerAmmo _projectile;
        };

        if (_unit distance _projectilePosition > WL_SAM_MAX_DISTANCE) then {
            triggerAmmo _projectile;
        };
    };
};

// Friendly fire check.
[_projectile, _unit] spawn {
    params ["_projectile", "_unit"];
    sleep 1;
    while { alive _projectile } do {
        sleep 0.2;
        private _missileTarget = missileTarget _projectile;
        private _missileTargetSide = [_missileTarget] call WL2_fnc_getAssetSide;
        private _projectileSide = side (group _unit);
        if (_missileTargetSide == _projectileSide) exitWith {
            triggerAmmo _projectile;
        };
    };
};

private _projectileType = typeOf _projectile;
private _projectileActualType = _projectile getVariable ["APS_ammoOverride", _projectileType];
private _projectileConfig = APS_projectileConfig getOrDefault [_projectileActualType, createHashMap];
private _projectileSpeedOverride = _projectileConfig getOrDefault ["speed", 1];
_projectileSpeedOverride = _projectileSpeedOverride max 1;
private _maxAcceleration = (getNumber (configfile >> "CfgAmmo" >> _projectileType >> "thrust")) * WL_SAM_ACCELERATION;
private _maxSpeed = getNumber (configfile >> "CfgAmmo" >> _projectileType >> "maxSpeed") * WL_SAM_MAX_SPEED_FACTOR * _projectileSpeedOverride;

// Sound barrier
if (speed _unit > 950) then {
    _maxSpeed = _maxSpeed * 3;
    _maxAcceleration = _maxAcceleration * 3;
};

private _terrainTest = 4000;
private _disableGroundAvoid = false;
#if WL_NO_GROUND_AVOID
_disableGroundAvoid = true;
#endif

private _lastLoopTime = serverTime;
while { alive _projectile } do {
    private _currentVector = velocityModelSpace _projectile;
    private _elapsedTime = serverTime - _lastLoopTime;
    private _currentSpeed = ((_currentVector # 1) + (_maxAcceleration * _elapsedTime)) min _maxSpeed;
    private _newVector = [
        0,
        _currentSpeed,
        0
    ];

    _projectile setVelocityModelSpace _newVector;

    private _notched = _projectile getVariable ["DIS_notched", false];
    if (_notched) then {
        _projectile setAngularVelocityModelSpace [0, 0, 0];
        sleep 0.001;
        continue;
    };

    private _angularVector = angularVelocityModelSpace _projectile;
    private _distanceTraveled = _projectile distance _originalPosition;
    if (_disableGroundAvoid || _distanceTraveled > 5000) then {
        private _newAngularVector = _angularVector vectorMultiply WL_SAM_ANGULAR_ACCELERATION;
        _projectile setAngularVelocityModelSpace _newAngularVector;
    } else {
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
        private _groundAvoid = !(_intersectPosition isEqualTo [0, 0, 0]) && _belowTargetATL;

        if (_groundAvoid) then {
            _projectile setAngularVelocityModelSpace [-30 * (_terrainTest -_distanceToGround) / _terrainTest, _angularVector # 1, _angularVector # 2];
        } else {
            private _newAngularVector = _angularVector vectorMultiply WL_SAM_ANGULAR_ACCELERATION;
            _projectile setAngularVelocityModelSpace _newAngularVector;
        };

        private _vectorUp = vectorUp _projectile;
        _vectorUp set [0, 0];
        _vectorUp set [1, 0];
        _projectile setVectorDirAndUp [vectorDir _projectile, _vectorUp];
    };

    _lastLoopTime = serverTime;
    sleep 0.001;
};
