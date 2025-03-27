#include "constants.inc"

params ["_target", "_projectile", "_launcher"];

private _targetVelocity = velocity _target;
private _projectileRelativeVelocity = _projectile vectorWorldToModel _targetVelocity;
_projectileRelativeVelocity set [2, 0];
private _normalizedVelocity = abs ((vectorNormalized _projectileRelativeVelocity) # 0);
private _perpendicularVelocity = abs (_projectileRelativeVelocity # 0);

private _targetPosition = getPosASL _originalTarget;
private _projectilePosition = getPosASL _projectile;
private _launcherPosition = getPosASL _launcher;

private _distanceRemaining = _projectilePosition distance _targetPosition;
private _distanceTraveled = _launcherPosition distance _projectilePosition;

private _targetTrackSpeed = if (_target isKindOf "Helicopter") then {
    25;
} else {
    80;
};
private _flareEffectRatio = (vectorMagnitude _targetVelocity) / (_targetTrackSpeed * 2.5);
private _flaresNearby = count (("CMflare_Chaff_Ammo" allObjects 2) select {
    (getShotParents _x) # 0 == _target || _x distance _target < 2000;
});
_flaresNearby = _flaresNearby * _flareEffectRatio;

private _actualTrackSpeed = _targetTrackSpeed - (_flaresNearby * 1.1);
private _actualTolerance = WL_SAM_NOTCH_TOLERANCE - (_flaresNearby * 0.02);
private _actualMaxRange = WL_SAM_NOTCH_MAX_RANGE - (_flaresNearby * 50);
_actualMaxRange = _actualMaxRange max 500;
private _excessSpeed = _perpendicularVelocity / _targetTrackSpeed;

_perpendicularVelocity > _actualTrackSpeed &&
_normalizedVelocity > _actualTolerance &&
_distanceRemaining > _actualMaxRange &&
_distanceTraveled > WL_SAM_NOTCH_ACTIVE_DIST &&
(_flaresNearby >= 4 || _excessSpeed > 2.5);