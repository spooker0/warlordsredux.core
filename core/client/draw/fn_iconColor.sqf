params [["_unit", objNull]];

if (isNull _unit) exitWith {
    switch (side group player) do {
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
};

if (_unit == player || player in crew _unit) exitWith {
    [1, 1, 0, 0.8]
};

if ((getPlayerChannel _unit) in [1, 2]) exitWith {
    [0, 0.8, 0, 0.8]
};

if (_unit in (units player) && _unit != player) exitWith {
    [0, 0.4, 0, 0.8]
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
    [0, 1, 1, 0.8]
};

private _unitSide = [_unit] call WL2_fnc_getAssetSide;
if (_unitSide == sideUnknown) then {
    _unitSide = side group player;
};
switch (_unitSide) do {
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