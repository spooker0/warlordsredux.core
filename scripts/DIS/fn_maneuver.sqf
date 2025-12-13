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
    private _selectedLockPercent = _unit getVariable ["WL2_selectedLockPercentAA", 0];
    if (!isNull _selectedTarget && isNull _originalTarget && _selectedLockPercent >= 100) then {
        private _isFlying = (_selectedTarget modelToWorld [0, 0, 0]) # 2 > 30;
        if (!_isFlying) exitWith {};
        private _unitSpeed = speed _unit;
        _projectile setVelocityModelSpace [0, _unitSpeed * 3.6 + 100, 0];
        _projectile setMissileTarget [_selectedTarget, true];
        _originalTarget = _selectedTarget;

        private _angleToEnemy = [getPosASL _unit, getDir _unit, getPosASL _selectedTarget] call WL2_fnc_getAngle;

        [_selectedTarget, _unit, _projectile] remoteExec ["WL2_fnc_warnIncomingMissile", _selectedTarget];

        uiSleep 1;

        private _projectilePos = getPosASL _projectile;
        private _targetPos = getPosASL _selectedTarget;

        private _targetVectorDirAndUp = [_projectilePos, _targetPos] call BIS_fnc_findLookAt;
        _projectile setVectorDirAndUp _targetVectorDirAndUp;

        _projectile setMissileTarget [_selectedTarget, true];

        private _projAlt = _projectilePos # 2;
        private _targetAlt = _targetPos # 2;
        if (_unitSpeed > WL_SAM_FAST_THRESHOLD) then {
            _distanceBeforeNotch = 5000 + (_projAlt - _targetAlt) * 2;
            private _angleToDistanceFactor = linearConversion [0, 180, _angleToEnemy, 1, 0, true];
            _distanceBeforeNotch = _distanceBeforeNotch * _angleToDistanceFactor;
            _distanceBeforeNotch = (_distanceBeforeNotch max 3500) min 12000;
        } else {
            _distanceBeforeNotch = 3500;
        };
    };
};

private _immunity = _ammoConfig getOrDefault ["immunity", 1500];
_distanceBeforeNotch = _distanceBeforeNotch max _immunity;

_projectile setVariable ["DIS_ultimateTarget", _originalTarget];

private _originalPosition = getPosASL _unit;
[_projectile, _originalTarget, _unit, _samMaxDistance, _distanceBeforeNotch] spawn {
    params ["_projectile", "_originalTarget", "_unit", "_samMaxDistance", "_distanceBeforeNotch"];
    private _startTime = serverTime;
    private _isLOAL = getNumber (configfile >> "CfgAmmo" >> typeOf _projectile >> "autoSeekTarget") == 1;

    while { alive _projectile } do {
        uiSleep 0.1;

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
        if (_notchResult >= 4) then {
            _projectile setVariable ["DIS_notched", true];
        };

        if (!isNull _originalTarget) then {
            private _canDodge = _projectile getVariable ["DIS_notched", false];
            if (!_canDodge) then {  // If not already notched and not notching
                private _targetVectorDirAndUp = [_projectilePosition, _targetPosition] call BIS_fnc_findLookAt;
                _projectile setVectorDirAndUp _targetVectorDirAndUp;
                _projectile setMissileTarget [_originalTarget, true];
            } else {
                if (_projectile distance2D _unit > 1000) then {
                    triggerAmmo _projectile;
                };
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
    uiSleep 1;
    while { alive _projectile } do {
        uiSleep 0.2;
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
        uiSleep 0.01;
        continue;
    };

    private _angularVector = angularVelocityModelSpace _projectile;

    private _newAngularVector = _angularVector vectorMultiply WL_SAM_ANGULAR_ACCELERATION;
    _projectile setAngularVelocityModelSpace _newAngularVector;

    _lastLoopTime = serverTime;
    uiSleep 0.01;
};