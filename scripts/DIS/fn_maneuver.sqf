#include "includes.inc"
params [
    "_projectile",
    "_unit",
    ["_samMaxDistance", WL_SAM_MAX_DISTANCE],
    ["_distanceBeforeNotch", WL_SAM_NOTCH_ACTIVE_DIST],
    ["_boostAltitude", 5000]
];

private _originalTarget = missileTarget _projectile;

if (_unit isKindOf "Air") then {
    _samMaxDistance = 30000;
} else {
    [_projectile, _originalTarget, _boostAltitude] call DIS_fnc_boostPhase;
};

private _assetActualType = _unit getVariable ["WL2_orderedClass", typeOf _unit];
private _hasLoal = WL_ASSET(_assetActualType, "hasLoal", 0) > 0;

if (_hasLoal) then {
    private _selectedTarget = _unit getVariable ["WL2_selectedTarget", objNull];
    if (!isNull _selectedTarget) then {
        _projectile setMissileTarget [_selectedTarget, true];
        _originalTarget = _selectedTarget;
    };
};

private _originalPosition = getPosASL _unit;
[_projectile, _originalTarget, _unit, _samMaxDistance, _distanceBeforeNotch] spawn {
    params ["_projectile", "_originalTarget", "_unit", "_samMaxDistance", "_distanceBeforeNotch"];
    private _startTime = serverTime;
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
        private _notchResult = [_originalTarget, _unit, _projectile, _distanceBeforeNotch] call DIS_fnc_getNotchResult;
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
if (speed _unit > 950) then {
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
        sleep 0.001;
        continue;
    };

    private _angularVector = angularVelocityModelSpace _projectile;
    private _distanceTraveled = _projectile distance _originalPosition;

    private _enemyVectorDirAndUp = [getPosASL _projectile, getPosASL _originalTarget] call BIS_fnc_findLookAt;
    _projectile setVectorDirAndUp _enemyVectorDirAndUp;

    _lastLoopTime = serverTime;
    sleep 0.001;
};
