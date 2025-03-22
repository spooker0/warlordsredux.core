#include "constants.inc"

params ["_display", "_number"];

private _num1 = floor (_number / 1000);
private _num2 = floor ((_number - _num1 * 1000) / 100);
private _num3 = floor ((_number - _num1 * 1000 - _num2 * 100) / 10);
private _num4 = _number % 10;
_display ctrlSetText format ["%1%2%3.%4", _num1, _num2, _num3, _num4];

private _lon = uiNamespace getVariable ["DIS_GPS_LON", 0];
private _lat = uiNamespace getVariable ["DIS_GPS_LAT", 0];
private _posATL = [_lon * 10, _lat * 10, 0];
private _posASL = ATLToASL _posATL;
private _heightASL = _posASL # 2;

private _display = ctrlParent _display;
private _heightDisplay = _display displayCtrl DIS_GPS_SEALEVEL;
private _color = if (_heightASL > 0) then {
    "#00ff00"
} else {
    "#ff0000"
};
_heightDisplay ctrlSetStructuredText parseText format [
    "<t color='%1' size='2' align='center'>%2 M</t><br/><t align='center' size='0.7'>ABOVE SEA LEVEL</t>",
    _color,
    round _heightASL
];

private _sectorDisplay = _display displayCtrl DIS_GPS_SECTOR;
private _closestSector = [BIS_WL_allSectors, [_posATL], {
    ((_x getVariable "objectAreaComplete") # 0) distance2D _input0
}, "ASCEND"] call BIS_fnc_sortBy;
_closestSector = _closestSector # 0;
private _sectorPos = _closestSector getVariable "objectAreaComplete";

private _prefix = "INSIDE";
private _color = "#00ff00";
if !(_posATL inArea _sectorPos) then {
    private _distance = _posATL distance2D (_sectorPos # 0);
    _prefix = format ["%1 KM FROM", (_distance / 1000) toFixed 1];
    _color = "#ff0000";
};
_sectorDisplay ctrlSetStructuredText parseText format [
    "<t align='center' size='1'>%1</t><br/><t align='center' size='1.2' color='%2'>%3</t>",
    _prefix,
    _color,
    toUpper (_closestSector getVariable ["BIS_WL_name", "UNKNOWN"])
];