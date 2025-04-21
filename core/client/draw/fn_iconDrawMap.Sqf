#include "..\..\warlords_constants.inc"

params ["_m"];

uiNamespace setVariable ["BIS_WL_mapControl", _m];

private _drawIcons = uiNamespace getVariable ["WL2_drawIcons", []];
private _drawIconsAnimated = uiNamespace getVariable ["WL2_drawIconsAnimated", []];
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