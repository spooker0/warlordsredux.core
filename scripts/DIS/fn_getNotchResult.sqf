#include "includes.inc"
params ["_target", "_launcher", "_projectile", ["_distanceBeforeNotch", WL_SAM_NOTCH_ACTIVE_DIST]];

private _targetVelocity = velocity _target;
private _projectileRelativeVelocity = _projectile vectorWorldToModel _targetVelocity;
_projectileRelativeVelocity set [2, 0];
private _normalizedVelocity = abs ((vectorNormalized _projectileRelativeVelocity) # 0);
private _perpendicularVelocity = abs (_projectileRelativeVelocity # 0);

private _distanceRemaining = _projectile distance _target;
private _distanceTraveled = _launcher distance _projectile;

private _targetAltitude = ASLtoAGL (getPosASL _target) # 2;
private _targetTrackSpeed = linearConversion [0, 4000, _targetAltitude, 40, 440, true];

private _launcherNoLos = _targetAltitude < 50 || terrainIntersectASL [getPosASL _launcher, getPosASL _target];
private _flaresNearby = count (("CMflare_Chaff_Ammo" allObjects 2) select {
    (getShotParents _x) # 0 == _target || _x distance _target < 4000;
});
if (_launcherNoLos) then {
    _flaresNearby = _flaresNearby * 10;
};

// systemChat format [
//     "Target speed: %1, Tolerance: %2, Max range: %3",
//     (_perpendicularVelocity / _targetTrackSpeed) min 1,
//     (_normalizedVelocity / WL_SAM_NOTCH_TOLERANCE) min 1,
//     (_distanceRemaining / WL_SAM_NOTCH_MAX_RANGE) min 1
// ];

_distanceBeforeNotch = if (speed _target > WL_SAM_FAST_THRESHOLD && speed _target > speed _launcher) then {
    6000;
} else {
    _distanceBeforeNotch;
};

private _trackSpeedPercent = (_perpendicularVelocity / _targetTrackSpeed) min 1;
private _tolerancePercent = (_normalizedVelocity / WL_SAM_NOTCH_TOLERANCE) min 1;
private _maxRangePercent = (_distanceRemaining / WL_SAM_NOTCH_MAX_RANGE) min 1;
private _distanceTraveledPercent = (_distanceTraveled / _distanceBeforeNotch) min 1;
private _flareBonus = _flaresNearby / 50;

_trackSpeedPercent + _tolerancePercent + _maxRangePercent + _distanceTraveledPercent + _flareBonus;