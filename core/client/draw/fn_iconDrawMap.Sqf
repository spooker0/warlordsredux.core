#include "..\..\warlords_constants.inc"

params ["_m"];

private _drawIcons = uiNamespace getVariable ["WL2_drawIcons", []];
private _drawIconsAnimated = uiNamespace getVariable ["WL2_drawIconsAnimated", []];
private _drawLines = uiNamespace getVariable ["WL2_drawLines", []];
private _drawEllipses = uiNamespace getVariable ["WL2_drawEllipses", []];

{
	_m drawIcon _x;
} forEach _drawIcons;
{
	_x set [5, (serverTime * 75) % 360];
	_m drawIcon _x;
} forEach _drawIconsAnimated;
{
	_m drawLine _x;
} forEach _drawLines;
{
	_m drawEllipse _x;
} forEach _drawEllipses;