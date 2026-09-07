#include "includes.inc"
params ["_warlord", "_uid"];

private _allPlayers = call BIS_fnc_listPlayers;
private _westNumber = count (_allPlayers select { side group _x == west });
private _eastNumber = count (_allPlayers select { side group _x == east });
private _playerCounts = [_westNumber, _eastNumber];

private _timeSinceStart = WL_DURATION_MISSION - (estimatedEndServerTime - serverTime);
private _withinGracePeriod = _timeSinceStart < 60;
if (_withinGracePeriod) exitWith {
    [[west, east], _playerCounts]
};

private _ratings = profileNamespace getVariable ["WL2_playerRatings", createHashMap];
private _playerElo = _ratings getOrDefault [_uid, WL_RATING_STARTER];
if (_playerElo <= WL_RATING_GATE) exitWith {
    if (_westNumber - _eastNumber > WL_RATING_NUMBALANCE) then {
        [[east], _playerCounts]
    } else {
        if (_eastNumber - _westNumber > WL_RATING_NUMBALANCE) then {
            [[west], _playerCounts]
        } else {
            [[west, east], _playerCounts]
        };
    };
};

private _eligibleSides = [];
private _squadParams = squadParams _warlord;
private _myUnit = if (count _squadParams > 3) then { _squadParams # 3 } else { "" };
if (_myUnit != "") then {
    {
        if (_x == _warlord) then {
            continue;
        };

        private _playerParams = squadParams _x;
        if (count _playerParams <= 3) then {
            continue;
        };

        private _playerUnit = _playerParams # 3;
        if (_playerUnit == _myUnit) then {
            private _playerSide = side group _x;
            _eligibleSides pushBackUnique _playerSide;
        };
    } forEach _allPlayers;
};

private _westElo = 0;
private _eastElo = 0;
private _westPlayersCount = 0;
private _eastPlayersCount = 0;
{
    private _playerRating = _ratings getOrDefault [getPlayerUID _x, WL_RATING_STARTER];
    private _side = side group _x;
    if (_side == west) then {
        _westElo = _westElo + (_playerRating min WL_RATING_EMAX);
        _westPlayersCount = _westPlayersCount + 1;
    };
    if (_side == east) then {
        _eastElo = _eastElo + (_playerRating min WL_RATING_EMAX);
        _eastPlayersCount = _eastPlayersCount + 1;
    };
} forEach _allPlayers;

if (_westPlayersCount == 0) then {
    _westPlayersCount = 1;
};
if (_eastPlayersCount == 0) then {
    _eastPlayersCount = 1;
};

private _westAverage = _westElo / _westPlayersCount;
private _eastAverage = _eastElo / _eastPlayersCount;

private _serverStats = profileNamespace getVariable ["WL_stats", createHashMap];
private _westWins = _serverStats getOrDefault ["westWins", 0];
private _eastWins = _serverStats getOrDefault ["eastWins", 0];
if (_westWins - _eastWins > 1) then {
    private _westWinDiff = _westWins - _eastWins;
    _westAverage = _westAverage + (_westWinDiff * 150);
};
if (_eastWins - _westWins > 1) then {
    private _eastWinDiff = _eastWins - _westWins;
    _eastAverage = _eastAverage + (_eastWinDiff * 150);
};

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
[_eligibleSides, [_westAverage, _eastAverage]];