#include "includes.inc"
params ["_startPoint", "_endPoint", "_screenBounds"];

// Clip a screen segment, then return [x, y, w, h] for RscLine.
// Bounds are native UI coordinates: [left, top, right, bottom], not 0..1.
if (count _startPoint != 2 || count _endPoint != 2) exitWith { [] };

_screenBounds params ["_screenLeft", "_screenTop", "_screenRight", "_screenBottom"];
_startPoint params ["_startX", "_startY"];
_endPoint params ["_endX", "_endY"];

private _deltaX = _endX - _startX;
private _deltaY = _endY - _startY;
if (_deltaX == 0 && _deltaY == 0) exitWith { [] };

private _boundaryTests = [
    [-_deltaX, _startX - _screenLeft],
    [ _deltaX, _screenRight - _startX],
    [-_deltaY, _startY - _screenTop],
    [ _deltaY, _screenBottom - _startY]
];

private _enterFraction = 0;
private _leaveFraction = 1;
private _visible = true;
{
    _x params ["_boundaryDelta", "_boundaryDistance"];

    if (abs _boundaryDelta < 1e-10) then {
        if (_boundaryDistance < 0) then {
            _visible = false;
        };
    } else {
        private _intersectionFraction = _boundaryDistance / _boundaryDelta;
        if (_boundaryDelta < 0) then {
            _enterFraction = _enterFraction max _intersectionFraction;
        } else {
            _leaveFraction = _leaveFraction min _intersectionFraction;
        };
    };

    if (!_visible || _enterFraction > _leaveFraction) exitWith {
        _visible = false;
    };
} forEach _boundaryTests;
if (!_visible || _enterFraction >= _leaveFraction) exitWith { [] };

private _clippedStartX = _startX + _enterFraction * _deltaX;
private _clippedStartY = _startY + _enterFraction * _deltaY;
private _clippedEndX = _startX + _leaveFraction * _deltaX;
private _clippedEndY = _startY + _leaveFraction * _deltaY;

// Keep width nonnegative, but preserve signed height (screen Y points down).
if (_clippedStartX > _clippedEndX) exitWith {
    private _lineWidth = _clippedStartX - _clippedEndX;
    private _lineHeight = _clippedStartY - _clippedEndY;

    [_clippedEndX, _clippedEndY, _lineWidth, _lineHeight]
};

private _lineWidth = _clippedEndX - _clippedStartX;
private _lineHeight = _clippedEndY - _clippedStartY;

[_clippedStartX, _clippedStartY, _lineWidth, _lineHeight]
