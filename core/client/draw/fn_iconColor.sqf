if (_x == player) exitWith {
    [1, 1, 0, 0.8]
};

if ((getPlayerChannel _x) in [1, 2]) exitWith {
    [0, 0.8, 0, 0.8]
};

if (_x in (units player) && _x != player) exitWith {
    [0, 0.4, 0, 0.8]
};

private _areInSquad = ["areInSquad", [getPlayerID _x, getPlayerID player]] call SQD_fnc_client;
if (isPlayer _x && _areInSquad) exitWith {
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