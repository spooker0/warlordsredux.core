#include "includes.inc"
// Pure UI renderer: rows are [missile name, [minimum, midpoint, maximum, distance, in window]].
params ["_display", "_header", "_controls", "_missiles", ["_fontScale", 1]];

disableSerialization;

while { count _controls > count _missiles } do {
    {
        ctrlDelete _x;
    } forEach (_controls deleteAt (count _controls - 1));
};

if (count _missiles == 0) exitWith {
    _controls;
};

private _position = ctrlPosition _header;
private _left = _position # 0;
private _top = (_position # 1) + ctrlTextHeight _header + 0.005;
private _width = _position # 2;
private _rowHeight = 0.07 * _fontScale;

{
    _x params ["_missileName", "_window"];

    if (_forEachIndex >= count _controls) then {
        private _row = [];
        for "_i" from 0 to 4 do {
            private _control = _display ctrlCreate ["RscText", -1];
            _control ctrlEnable false;
            _row pushBack _control;
        };

        private _missileMarker = _display ctrlCreate ["RscPictureKeepAspect", -1];
        _missileMarker ctrlEnable false;
        _missileMarker ctrlSetText "\A3\ui_f\data\map\markers\nato\o_unknown.paa";
        _row pushBack _missileMarker;

        _controls pushBack _row;
    };

    private _row = _controls # _forEachIndex;
    _row params ["_label", "_line", "_band", "_minimumTick", "_maximumTick", "_missileMarker"];

    private _rowTop = _top + _forEachIndex * _rowHeight;
    private _barTop = _rowTop + 0.043 * _fontScale;
    private _distanceText = format [localize "STR_WL_distanceKilometers", ((_window # 3) / 1000) toFixed 1];
    _label ctrlSetText format ["%1 - %2", _missileName, _distanceText];
    _label ctrlSetFont "EtelkaMonospaceProBold";
    _label ctrlSetFontHeight (0.028 * _fontScale);
    _label ctrlSetTextColor [0.078, 0.796, 0, 1];
    _label ctrlSetShadow 2;
    _label ctrlSetPosition [_left, _rowTop, _width, 0.03 * _fontScale];
    _label ctrlCommit 0;

    _window params [
        ["_minimumRange", 0],
        ["_midpointRange", 0],
        ["_maximumRange", 0],
        ["_distance", 0],
        ["_inRange", false]
    ];

    private _scale = 10000;
    private _diamondHeight = 0.021 * _fontScale;
    private _diamondWidth = _diamondHeight * pixelW / pixelH;
    private _barLeft = _left + _diamondWidth / 2;
    private _barWidth = _width - _diamondWidth;
    private _rangePositions = [_minimumRange, _maximumRange, _distance] apply {
        _barLeft + (linearConversion [0, _scale, _x, 0, _barWidth, true]);
    };

    private _hasWindow = _minimumRange < _maximumRange;
    private _lineColor = if (_hasWindow) then {
        [0.65, 0.65, 0.65, 0.8];
    } else {
        [1, 0, 0, 0.8];
    };
    _line ctrlSetBackgroundColor _lineColor;
    _line ctrlSetPosition [_barLeft, _barTop, _barWidth, pixelH];
    _line ctrlShow true;

    private _bandColor = if (_inRange) then {
        [0.2, 1, 0.2, 0.8];
    } else {
        [0.2, 0.6, 0.2, 0.5];
    };
    _band ctrlSetBackgroundColor _bandColor;
    _band ctrlSetPosition [_rangePositions # 0, _barTop - 0.003 * _fontScale, (_rangePositions # 1) - (_rangePositions # 0), 0.006 * _fontScale];
    _band ctrlShow _hasWindow;

    private _tickWidth = 2 * pixelW;
    {
        _x ctrlShow _hasWindow;
        _x ctrlSetBackgroundColor [0.2, 1, 0.2, 1];
        _x ctrlSetPosition [(_rangePositions # _forEachIndex) - _tickWidth / 2, _barTop - 0.012 * _fontScale, _tickWidth, 0.018 * _fontScale];
    } forEach [_minimumTick, _maximumTick];

    _missileMarker ctrlSetTextColor [1, 0, 0, 1];
    _missileMarker ctrlSetPosition [(_rangePositions # 2) - _diamondWidth / 2, _barTop + (pixelH - _diamondHeight) / 2, _diamondWidth, _diamondHeight];
    _missileMarker ctrlShow true;

    {
        _x ctrlCommit 0;
    } forEach _row;
} forEach _missiles;

_controls;
