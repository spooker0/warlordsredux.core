#include "includes.inc"
params ["_m"];

uiNamespace setVariable ["BIS_WL_mapControl", _m];

private _drawIcons = uiNamespace getVariable ["WL2_drawIcons", []];
private _drawIconsAnimated = uiNamespace getVariable ["WL2_drawIconsAnimated", []];
private _drawIconsFollowMouse = uiNamespace getVariable ["WL2_drawIconsFollowMouse", []];
private _drawLines = uiNamespace getVariable ["WL2_drawLines", []];
private _drawEllipses = uiNamespace getVariable ["WL2_drawEllipses", []];
private _drawSemiCircles = uiNamespace getVariable ["WL2_drawSemiCircles", []];
private _drawRectangles = uiNamespace getVariable ["WL2_drawRectangles", []];
private _drawPolygons = uiNamespace getVariable ["WL2_drawPolygons", []];

{
    _x params ["_points", "_color", "_fill"];

    if (count _points < 3) then {
		continue;
	};

    private _anchor = _points # (count _points - 1);

    for "_i" from 0 to (count _points - 3) do {
        private _triangle = [
            _points # _i,
            _points # (_i + 1),
            _anchor
        ];
        _m drawTriangle [_triangle, _color, _fill];
    };
} forEach _drawPolygons;

{
	_m drawIcon _x;
} forEach _drawIcons;

private _angle = (serverTime * 75) % 360;
{
	_x set [5, _angle];
	_m drawIcon _x;
} forEach _drawIconsAnimated;

private _scale = ctrlMapScale _m;
{
	private _icon = +_x;
	private _mousePosition = getMousePosition;
	_mousePosition = _mousePosition vectorAdd (_icon # 2);
	private _mapPosition = _m ctrlMapScreenToWorld _mousePosition;
	_icon set [2, _mapPosition];

	private _textScale = _icon # 8;
	private _textSize = linearConversion [0.05, 0.1, _scale, _textScale / 2, _textScale, true];
	_icon set [8, _textSize];

	_m drawIcon _icon;
} forEach _drawIconsFollowMouse;

{
	_m drawLine _x;
} forEach _drawLines;

{
	_m drawEllipse _x;
} forEach _drawEllipses;

private _circleScale = 6.4 * worldSize / 8192 * _scale;
{
	_x params ["_sectorAngle", "_color", "_position", "_size", "_direction", "_scanLines"];
	_m drawIcon [
		format ["\a3\ui_f\data\IGUI\RscCustomInfo\Sensors\Sectors\sector%1_ca.paa", _sectorAngle],
		_color,
		_position,
		_size / _circleScale,
		_size / _circleScale,
		_direction
	];

	// if (!_scanLines) then {
	// 	continue;
	// };

	// private _scanAngleStart = _direction - (_sectorAngle / 2);
	// private _scanAngleEnd = _direction + (_sectorAngle / 2);
	// private _scanAngleActual = linearConversion [0, 2, serverTime % 2, _scanAngleStart, _scanAngleEnd, true];
	// _m drawLine [
	// 	_position,
	// 	_position getPos [_size * 0.95, _scanAngleActual],
	// 	[1, 1, 1, 0.3],
	// 	6
	// ];
} forEach _drawSemiCircles;

{
	_m drawRectangle _x;
} forEach _drawRectangles;

if (WL_IsReplaying) then {
	private _drawSectorIcons = uiNamespace getVariable ["WL2_drawSectorIcons", []];
	{
		_m drawIcon _x;
	} forEach _drawSectorIcons;
};

uiNamespace setVariable ["WL2_drawingMap", true];