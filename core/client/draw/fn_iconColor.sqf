#include "includes.inc"
params ["_unit", "_mapColorCache"];

private _colorFromCache = _mapColorCache getOrDefault [hashValue _unit, []];
if (count _colorFromCache == 4) exitWith {
    _colorFromCache;
};

if (isNull _unit) exitWith {
    private _color = switch (side group player) do {
        case west: {
            [0, 0.3, 0.6, 0.8]
        };
        case east: {
            [0.5, 0, 0, 0.8]
        };
        case resistance: {
            [0, 0.6, 0, 0.8]
        };
        default {
            [0.4, 0, 0.5, 0.8]
        }
    };
    _mapColorCache set [hashValue _unit, _color];
    _color;
};

if (_unit == player || player in crew _unit) exitWith {
    private _color = [1, 1, 0, 1];
    _mapColorCache set [hashValue _unit, _color];
    _color;
};

if (_unit in (units player) && _unit != player) exitWith {
    private _color = [0.7, 0.7, 0, 0.8];
    _mapColorCache set [hashValue _unit, _color];
    _color;
};

private _playerID = getPlayerID player;

private _areInSquad = if (isPlayer _unit) then {
    ["areInSquad", [getPlayerID _unit, _playerID]] call SQD_fnc_client;
} else {
    private _playerCrew = (crew _unit) select {
        isPlayer _x
    };
    private _anyInSquad = false;
    {
        private _crewInSquad = ["areInSquad", [getPlayerID _x, _playerID]] call SQD_fnc_client;
        if (_crewInSquad) then {
            _anyInSquad = true;
            break;
        };
    } forEach _playerCrew;
    _anyInSquad
};
if (_areInSquad) exitWith {
    private _color = [0, 1, 1, 0.8];
    _mapColorCache set [hashValue _unit, _color];
    _color;
};

private _unitSide = [_unit] call WL2_fnc_getAssetSide;
if (_unitSide == sideUnknown) then {
    _unitSide = side group player;
};

private _color = switch (_unitSide) do {
    case west: {
        [0, 0.3, 0.6, 0.8]
    };
    case east: {
        [0.5, 0, 0, 0.8]
    };
    case resistance: {
        [0, 0.6, 0, 0.8]
    };
    default {
        [0.4, 0, 0.5, 0.8]
    }
};
_mapColorCache set [hashValue _unit, _color];
_color;