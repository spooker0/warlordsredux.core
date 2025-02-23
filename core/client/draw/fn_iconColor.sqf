if (_x == player || player in crew _x) exitWith {
    [1, 1, 0, 0.8]
};

if ((getPlayerChannel _x) in [1, 2]) exitWith {
    [0, 0.8, 0, 0.8]
};

if (_x in (units player) && _x != player) exitWith {
    [0, 0.4, 0, 0.8]
};

private _areInSquad = if (isPlayer _x) then {
    ["areInSquad", [getPlayerID _x, getPlayerID player]] call SQD_fnc_client;
} else {
    private _playerCrew = (crew _x) select {
        isPlayer _x
    };
    private _anyInSquad = false;
    {
        private _crewInSquad = ["areInSquad", [getPlayerID _x, getPlayerID player]] call SQD_fnc_client;
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

switch (BIS_WL_playerSide) do {
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