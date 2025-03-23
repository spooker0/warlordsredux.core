params ["_asset"];

private _lon = uiNamespace getVariable ["DIS_GPS_LON", 0];
private _lat = uiNamespace getVariable ["DIS_GPS_LAT", 0];
private _posATL = [_lon * 100, _lat * 100, 0];
private _targetPos = ATLToASL _posATL;

private _launcherPos = getPosASL _asset;
private _launcherVelocity = velocity _asset;

private _vectorDiff = _targetPos vectorDiff _launcherPos;
private _vectorDiffNormalized = vectorNormalized _vectorDiff;
private _relativeVelocity = _launcherVelocity vectorDotProduct _vectorDiffNormalized;

private _altitude = _launcherPos # 2;
private _timeToGround = sqrt (_altitude / 5);
private _range = _timeToGround * (_relativeVelocity + 200);

private _distanceNeeded = _targetPos distance2D _launcherPos;
private _inRange = _range > _distanceNeeded;

[_inRange, _range, _distanceNeeded, _posATL]