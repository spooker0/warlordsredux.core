#include "includes.inc"
params ["_warlord", "_uid"];

private _timeSinceStart = WL_DURATION_MISSION - (estimatedEndServerTime - serverTime);
private _withinGracePeriod = _timeSinceStart < 60;
if (_withinGracePeriod) exitWith { [west, east] };

private _ratings = profileNamespace getVariable ["WL2_playerRatings", createHashMap];
private _playerElo = _ratings getOrDefault [_uid, WL_RATING_STARTER];
if (_playerElo <= WL_RATING_GATE) exitWith {
    private _westNumber = playersNumber west;
    private _eastNumber = playersNumber east;

    if (_westNumber - _eastNumber > WL_RATING_NUMBALANCE) then {
        [east]
    } else {
        if (_eastNumber - _westNumber > WL_RATING_NUMBALANCE) then {
            [west]
        } else {
            [west, east]
        };
    };
};

private _eligibleSides = [];
private _myUnit = squadParams _warlord # 3;
if (_myUnit != "") then {
    {
        if (_x == _warlord) then {
            continue;
        };
        private _playerUnit = squadParams _x # 3;
        if (_playerUnit == _myUnit) then {
            private _playerSide = side group _x;
            _eligibleSides pushBackUnique _playerSide;
        };
    } forEach allPlayers;
};

private _serverStats = profileNamespace getVariable ["WL_stats", createHashMap];

private _westElo = 0;
private _eastElo = 0;
private _westPlayersCount = 0;
private _eastPlayersCount = 0;
{
    private _playerRating = _ratings getOrDefault [getPlayerUID _x, WL_RATING_STARTER];
    private _side = side group _x;
    if (_side == west) then {
        _westElo = _westElo + _playerRating;
        _westPlayersCount = _westPlayersCount + 1;
    };
    if (_side == east) then {
        _eastElo = _eastElo + _playerRating;
        _eastPlayersCount = _eastPlayersCount + 1;
    };
} forEach allPlayers;

if (_westPlayersCount == 0) exitWith { [west, east] };
if (_eastPlayersCount == 0) exitWith { [west, east] };

private _westAverage = _westElo / _westPlayersCount;
private _eastAverage = _eastElo / _eastPlayersCount;

if (_westAverage - _eastAverage < 100) then {
    _eligibleSides pushBackUnique west;
};
if (_eastAverage - _westAverage < 100) then {
    _eligibleSides pushBackUnique east;
};

if (count _eligibleSides == 0) then {
    // should not happen
    _eligibleSides = [west, east];
};
_eligibleSides;