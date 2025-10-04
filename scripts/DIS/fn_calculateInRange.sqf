#include "includes.inc"
params ["_asset"];

private _cords = cameraOn getVariable ["DIS_gpsCord", ""];
while { count _cords < 6 } do {
    _cords = "0" + _cords;
};
private _lon = parseNumber (_cords select [0, 3]);
private _lat = parseNumber (_cords select [3, 3]);

private _posATL = [_lon * 100, _lat * 100, 0];
private _targetPos = ATLToASL _posATL;

private _launcherPos = getPosASL _asset;
private _launcherVelocity = velocity _asset;

private _vectorDiff = _targetPos vectorDiff _launcherPos;
private _vectorDiffNormalized = vectorNormalized _vectorDiff;
private _relativeVelocity = _launcherVelocity vectorDotProduct _vectorDiffNormalized;

private _altitude = (_launcherPos # 2) max 1;
private _timeToGround = sqrt (_altitude / 5);
private _range = _timeToGround * (_relativeVelocity + 200);

private _distanceNeeded = _targetPos distance2D _launcherPos;
private _overrideRange = _asset getVariable ["WL2_overrideRange", 0];
if (_overrideRange > 0) then {
	_range = _overrideRange;
};
private _inRange = _range > _distanceNeeded && _distanceNeeded > 500;

[_inRange, _range, _distanceNeeded, _posATL]