#include "includes.inc"
params ["_m"];

uiNamespace setVariable ["BIS_WL_mapControl", _m];

private _drawIcons = uiNamespace getVariable ["WL2_drawIcons", []];
private _drawIconsAnimated = uiNamespace getVariable ["WL2_drawIconsAnimated", []];
private _drawIconsFollowMouse = uiNamespace getVariable ["WL2_drawIconsFollowMouse", []];
private _drawLines = uiNamespace getVariable ["WL2_drawLines", []];
private _drawEllipses = uiNamespace getVariable ["WL2_drawEllipses", []];

{
	_m drawIcon _x;
} forEach _drawIcons;

private _angle = (serverTime * 75) % 360;
{
	_x set [5, _angle];
	_m drawIcon _x;
} forEach _drawIconsAnimated;

{
	private _icon = +_x;
	private _mousePosition = getMousePosition;
	_mousePosition = _mousePosition vectorAdd (_icon # 2);
	private _mapPosition = _m ctrlMapScreenToWorld _mousePosition;
	_icon set [2, _mapPosition];

	private _textScale = _icon # 8;
	private _textSize = linearConversion [0.05, 0.1, ctrlMapScale _m, _textScale / 2, _textScale, true];
	_icon set [8, _textSize];

	_m drawIcon _icon;
} forEach _drawIconsFollowMouse;

{
	_m drawLine _x;
} forEach _drawLines;

{
	_m drawEllipse _x;
} forEach _drawEllipses;

if (WL_IsReplaying) then {
	private _drawSectorIcons = uiNamespace getVariable ["WL2_drawSectorIcons", []];
	{
		_m drawIcon _x;
	} forEach _drawSectorIcons;
};

uiNamespace setVariable ["WL2_drawingMap", true];