#include "includes.inc"
params ["_area"];

private _center = _area # 0;
private _radius = sqrt ((_area # 1) ^ 2 + (_area # 2) ^ 2);

private _startX = (_center # 0) - _radius;
private _startY = (_center # 1) - _radius;
private _endX = (_center # 0) + _radius;
private _endY = (_center # 1) + _radius;

private _allowDistance = 3;
private _axisStep = 10;

private _allPositions = [];
for "_yCoord" from _startY to _endY step _axisStep do {
	for "_xCoord" from _startX to _endX step _axisStep do {
		private _coordinate = [_xCoord, _yCoord, 0];
		_allPositions pushBack _coordinate;
	};
};

_allPositions = _allPositions inAreaArray _area;
_allPositions = _allPositions select { !surfaceIsWater _x } select {
    private _result = _x isFlatEmpty [_allowDistance, -1, 0.35, _allowDistance, 0, false, objNull];
    count _result > 0 || isOnRoad _x
};

private _allPositions = if (count _allPositions == 0) then {
    [_center];
} else {
    _allPositions;
};
_allPositions;