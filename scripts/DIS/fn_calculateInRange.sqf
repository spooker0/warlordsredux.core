params ["_targetPos", "_launcherPos", "_launcherVelocity"];
private _vectorDiff = _targetPos vectorDiff _launcherPos;
private _vectorDiffNormalized = vectorNormalized _vectorDiff;
private _relativeVelocity = _launcherVelocity vectorDotProduct _vectorDiffNormalized;

private _altitude = _launcherPos # 2;
private _timeToGround = sqrt (_altitude / 5);
private _range = _timeToGround * (_relativeVelocity + 200);

private _distanceNeeded = _targetPos distance2D _launcherPos;
private _inRange = _range > _distanceNeeded;

[_inRange, _range, _distanceNeeded]