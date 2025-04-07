#include "constants.inc"

params ["_target", "_projectile", "_launcher"];

private _targetVelocity = velocity _target;
private _projectileRelativeVelocity = _projectile vectorWorldToModel _targetVelocity;
_projectileRelativeVelocity set [2, 0];
private _normalizedVelocity = abs ((vectorNormalized _projectileRelativeVelocity) # 0);
private _perpendicularVelocity = abs (_projectileRelativeVelocity # 0);

private _distanceRemaining = _projectile distance _target;
private _distanceTraveled = _launcher distance _projectile;

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
private _actualTolerance = WL_SAM_NOTCH_TOLERANCE - (_flaresNearby * 0.015);    // 67 flares max
private _actualMaxRange = WL_SAM_NOTCH_MAX_RANGE - (_flaresNearby * 50);        // 40 flares max
_actualMaxRange = _actualMaxRange max 500;

_perpendicularVelocity > _actualTrackSpeed &&
_normalizedVelocity > _actualTolerance &&
_distanceRemaining > _actualMaxRange &&
_distanceTraveled > WL_SAM_NOTCH_ACTIVE_DIST;