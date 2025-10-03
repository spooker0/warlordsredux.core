#include "includes.inc"
params ["_marker"];

private _center = markerPos _marker;
private _size = markerSize _marker;
private _isRectangle = markerShape _marker == "RECTANGLE";

private _area = [_center, _size # 0, _size # 1, 0, _isRectangle];
private _allPositions = [_area] call WL2_fnc_findSpawnsInArea;

if (count _allPositions == 0) then {
    _allPositions = [_center];
};
_allPositions;