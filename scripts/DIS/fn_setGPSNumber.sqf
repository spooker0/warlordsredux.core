#include "constants.inc"

params ["_control", "_number"];

private _num1 = floor (_number / 100);
private _num2 = floor ((_number - _num1 * 100) / 10);
private _num3 = _number - _num1 * 100 - _num2 * 10;
_control ctrlSetText format ["%1%2%3", _num1, _num2, _num3];

private _lon = uiNamespace getVariable ["DIS_GPS_LON", 0];
private _lat = uiNamespace getVariable ["DIS_GPS_LAT", 0];
private _posATL = [_lon * 100, _lat * 100, 0];
private _posASL = ATLToASL _posATL;
private _heightASL = _posASL # 2;