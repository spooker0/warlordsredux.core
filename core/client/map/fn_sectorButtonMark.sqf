#include "..\..\warlords_constants.inc"

params ["_sector", "_isNext"];
private _side = BIS_WL_playerSide;
private _mapMarkerVar = format ["WL2_MapMarker_%1", _side];
private _mapMarkedByVar = format ["WL2_MapMarkedBy_%1", _side];
private _mapMarkedTimeVar = format ["WL2_MapMarkedTime_%1", _side];

private _currentMarker = _sector getVariable [_mapMarkerVar, "unknown"];

private _allMarkers = ["unknown", "enemy", "enemyhome", "green", "attack", "attack2", "camped"];
private _currentIndex = _allMarkers find _currentMarker;
private _nextMarker = if (_isNext) then {
    _allMarkers # ((_currentIndex + 1) % count _allMarkers)
} else {
    _allMarkers # ((_currentIndex - 1) % count _allMarkers)
};

private _markedByLast = _sector getVariable [_mapMarkedByVar, ""];
private _playerName = [player, true] call BIS_fnc_getName;
if (_markedByLast != _playerName) then {
    _sector setVariable [_mapMarkedByVar, _playerName, true];

    private _start = missionNamespace getVariable ["gameStart", 0];
    private _gameTimer = [36000 - (serverTime - _start), "HH:MM"] call BIS_fnc_secondsToString;
    _sector setVariable [_mapMarkedTimeVar, _gameTimer, true];
};
_sector setVariable [_mapMarkerVar, _nextMarker, true];

// return new text and color
([_sector, _side] call WL2_fnc_sectorButtonMarker) # 0;