#include "includes.inc"
params [
    "_projectile",
    "_unit",
    ["_groundAvoidDistance", 5000],
    ["_samMaxDistance", WL_SAM_MAX_DISTANCE],
    ["_distanceBeforeNotch", WL_SAM_NOTCH_ACTIVE_DIST]
];

private _detectors = vehicles select { alive _x } 
    select { count crew _x > 0 } 
    select { [_x] call WL2_fnc_getAssetSide != [_unit] call WL2_fnc_getAssetSide }
    select { ((getPosATL _x) # 2) > 50 }
    select {
        private _detectionRadius = _x getVariable ["DIS_missileDetector", 0];
        _detectionRadius > 0 && (_x distance2D _projectile) < _detectionRadius
    };

if (count _detectors > 0) then {
    private _detectorSide = [_detectors # 0] call WL2_fnc_getAssetSide;
    [[_unit], 5] remoteExec ["WL2_fnc_reportTargets", _detectorSide];
};

private _munitionList = _unit getVariable ["DIS_munitionList", []];
_munitionList pushBack _projectile;
_munitionList = _munitionList select { alive _x };
_unit setVariable ["DIS_munitionList", _munitionList];

if (_unit isKindOf "Air") then {
    _samMaxDistance = 30000;
};

private _ammo = typeof _projectile;
private _ammoSensors = "true" configClasses (configfile >> "CfgAmmo" >> _ammo >> "Components" >> "SensorsManagerComponent" >> "Components");
_ammoSensors = _ammoSensors apply { configName _x };
private _missileType = if ("IRSensorComponent" in _ammoSensors) then { 2 } else { 3 };
_projectile setVariable ["WL2_missileType", format ["FOX-%1", _missileType]];

private _originalTarget = missileTarget _projectile;

private _ammoConfig = _unit getVariable ["WL2_currentAmmoConfig", createHashMap];
if (_ammoConfig getOrDefault ["loal", false]) then {
    private _selectedTarget = _unit getVariable ["WL2_selectedTargetAA", objNull];
    if (!isNull _selectedTarget && isNull _originalTarget) then {
        private _unitSpeed = speed _unit;
        _projectile setVelocityModelSpace [0, _unitSpeed * 3.6 + 100, 0];
        _projectile setMissileTarget [_selectedTarget, true];
        _originalTarget = _selectedTarget;
        
        sleep 1;

        private _projectilePos = getPosASL _projectile;
        private _targetPos = getPosASL _selectedTarget;
        
        private _targetVectorDirAndUp = [_projectilePos, _targetPos] call BIS_fnc_findLookAt;
        _projectile setVectorDirAndUp _targetVectorDirAndUp;

        _projectile setMissileTarget [_selectedTarget, true];

        private _projAlt = _projectilePos # 2;
        private _targetAlt = _targetPos # 2;
        if (_unitSpeed > WL_SAM_FAST_THRESHOLD) then {
            if (_projAlt > _targetAlt) then {
                _distanceBeforeNotch = 48000;
            } else {
                _distanceBeforeNotch = 5000 + (_projAlt - _targetAlt) * 2;
                _distanceBeforeNotch = _distanceBeforeNotch max 3500;
            };
        } else {
            _distanceBeforeNotch = 3500;
        };
    };
};
_projectile setVariable ["DIS_ultimateTarget", _originalTarget];

private _originalPosition = getPosASL _unit;
[_projectile, _originalTarget, _unit, _samMaxDistance, _distanceBeforeNotch] spawn {
    params ["_projectile", "_originalTarget", "_unit", "_samMaxDistance", "_distanceBeforeNotch"];
    private _startTime = serverTime;
    private _isLOAL = getNumber (configfile >> "CfgAmmo" >> typeOf _projectile >> "autoSeekTarget") == 1;
    private _lockSpeed = getNumber (configfile >> "CfgAmmo" >> typeOf _projectile >> "missileLockMaxSpeed");
    _lockSpeed = _lockSpeed * 3.6 / 1.5;

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
        private _notchResult = [_originalTarget, _unit, _projectile, _distanceBeforeNotch] call DIS_fnc_getNotchResult;
        if (_notchResult == 4) then {
            _projectile setVariable ["DIS_notched", true];
        };
        
        if (!isNull _originalTarget) then {
            private _canDodge = _projectile getVariable ["DIS_notched", false] || speed _originalTarget > (WL_SAM_FAST_THRESHOLD min _lockSpeed);
            if (!_canDodge) then {  // If not already notched and not notching
                private _targetVectorDirAndUp = [_projectilePosition, _targetPosition] call BIS_fnc_findLookAt;
                _projectile setVectorDirAndUp _targetVectorDirAndUp;
                _projectile setMissileTarget [_originalTarget, true];
            } else {
                _projectile setMissileTarget [objNull, true];
            };
        };

        private _currentMissileTarget = missileTarget _projectile;
        // Ghost missile relocking check.
        if (_isLOAL && alive _currentMissileTarget && _currentMissileTarget != _originalTarget) then {
            triggerAmmo _projectile;
        };

        if (_unit distance _projectilePosition > _samMaxDistance) then {
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
private _maxAcceleration = (getNumber (configfile >> "CfgAmmo" >> _projectileType >> "thrust")) * WL_SAM_ACCELERATION * _projectileSpeedOverride;
private _maxSpeed = getNumber (configfile >> "CfgAmmo" >> _projectileType >> "maxSpeed") * WL_SAM_MAX_SPEED_FACTOR * _projectileSpeedOverride;

// Sound barrier
if (speed _unit > WL_SAM_FAST_THRESHOLD) then {
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
        sleep 0.01;
        continue;
    };

    private _angularVector = angularVelocityModelSpace _projectile;
    private _distanceTraveled = _projectile distance _originalPosition;
    if (_disableGroundAvoid || _distanceTraveled > _groundAvoidDistance) then {
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
    sleep 0.01;
};