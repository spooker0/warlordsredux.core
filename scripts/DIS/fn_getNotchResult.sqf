#include "constants.inc"

params ["_target", "_launcher", ["_projectile", objNull]];

private _targetVelocity = velocity _target;
private _projectileRelativeVelocity = if (isNull _projectile) then {
    private _weaponDir = _launcher weaponDirection (currentWeapon _launcher);
    private _upWorld = [0,0,1];

    private _right = _weaponDir vectorCrossProduct _upWorld;
    _right = vectorNormalized _right;
    private _up = _right vectorCrossProduct _weaponDir;
    _up = vectorNormalized _up;
    private _velR = _targetVelocity vectorDotProduct _right;
    private _velU = _targetVelocity vectorDotProduct _up;
    [_velR, _velU, 0];
} else {
    _projectile vectorWorldToModel _targetVelocity
};
_projectileRelativeVelocity set [2, 0];
private _normalizedVelocity = abs ((vectorNormalized _projectileRelativeVelocity) # 0);
private _perpendicularVelocity = abs (_projectileRelativeVelocity # 0);

private _distanceRemaining = if (isNull _projectile) then {
    _launcher distance _target
} else {
    _projectile distance _target
};
private _distanceTraveled = if (isNull _projectile) then {
    0
} else {
    _launcher distance _projectile
};

private _targetAltitude = ASLtoAGL (getPosASL _target) # 2;
private _targetTrackSpeed = linearConversion [0, 4000, _targetAltitude, 40, 440, true];

private _launcherNoLos = terrainIntersectASL [getPosASL _launcher, getPosASL _target];
private _flaresNearby = count (("CMflare_Chaff_Ammo" allObjects 2) select {
    (getShotParents _x) # 0 == _target || _x distance _target < 2000;
});
if (_launcherNoLos) then {
    _flaresNearby = _flaresNearby * 2;
};

private _actualTrackSpeed = _targetTrackSpeed - (_flaresNearby * 15);           // 30 flares max
private _actualTolerance = WL_SAM_NOTCH_TOLERANCE - (_flaresNearby * 0.012);    // 74 flares max
private _actualMaxRange = WL_SAM_NOTCH_MAX_RANGE - (_flaresNearby * 50);        // 40 flares max
_actualTrackSpeed = _actualTrackSpeed max 1;
_actualTolerance = _actualTolerance max 0.1;
_actualMaxRange = _actualMaxRange max 500;

// systemChat format [
//     "Target speed: %1, Tolerance: %2, Max range: %3",
//     (_perpendicularVelocity / _actualTrackSpeed) min 1,
//     (_normalizedVelocity / _actualTolerance) min 1,
//     (_distanceRemaining / _actualMaxRange) min 1
// ];

private _trackSpeedPercent = (_perpendicularVelocity / _actualTrackSpeed) min 1;
private _tolerancePercent = (_normalizedVelocity / _actualTolerance) min 1;
private _maxRangePercent = (_distanceRemaining / _actualMaxRange) min 1;
private _distanceTraveledPercent = (_distanceTraveled / WL_SAM_NOTCH_ACTIVE_DIST) min 1;

if (isNull _projectile) then {
    if (_maxRangePercent < 1) then {
        1
    } else {
        2 - (_trackSpeedPercent + _tolerancePercent);
    };
} else {
    _trackSpeedPercent + _tolerancePercent + _maxRangePercent + _distanceTraveledPercent;
};