#include "includes.inc"
params ["_display", "_map", "_position", "_text", "_color", "_offset", "_size", ["_widthScale", 0.34]];

private _layer = _display displayCtrl TUT_LABELS_IDC;
private _pool = _display getVariable ["TUT_labelPool", []];
private _index = _display getVariable ["TUT_labelCount", 0];
if (_index >= count _pool) then {
    private _label = _display ctrlCreate ["TUT_MapLabel", -1, _layer];
    _label ctrlEnable false;
    _pool pushBack _label;
    _display setVariable ["TUT_labelPool", _pool];
};
private _label = _pool # _index;
_display setVariable ["TUT_labelCount", _index + 1];

private _screen = _map ctrlMapWorldToScreen _position;
private _origin = ctrlPosition _layer;
private _fontSize = safeZoneH * _size * 0.8;
private _width = safeZoneW * _widthScale;
private _height = _fontSize * 1.5;
_label ctrlSetText _text;
_label ctrlSetTextColor _color;
_label ctrlSetFontHeight _fontSize;
_label ctrlSetPosition [
    (_screen # 0) + (_offset # 0) - (_origin # 0) - _width * 0.5,
    (_screen # 1) + (_offset # 1) - (_origin # 1) - _height * 0.5,
    _width,
    _height
];
_label ctrlCommit 0;
_label ctrlShow true;
