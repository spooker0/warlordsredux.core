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
private _flaresNearby = count (_target nearObjects ["CMflare_Chaff_Ammo", 300]);

private _actualTolerance = WL_SAM_NOTCH_TOLERANCE - (_flaresNearby * 0.01);

private _kinematicEligible = _perpendicularVelocity > _targetTrackSpeed &&
_normalizedVelocity > _actualTolerance &&
_distanceRemaining > WL_SAM_NOTCH_MAX_RANGE &&
_distanceTraveled > WL_SAM_NOTCH_ACTIVE_DIST;

if !(_kinematicEligible) exitWith { false };

private _excessSpeed = _perpendicularVelocity / _targetTrackSpeed;

_flaresNearby >= 5 || _excessSpeed > 2.5;