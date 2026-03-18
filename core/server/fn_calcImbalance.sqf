params ["_currentSide", "_uid"];
private _serverStats = profileNamespace getVariable ["WL_stats", createHashMap];

private _westWins = _serverStats getOrDefault ["westWins", 0];
private _eastWins = _serverStats getOrDefault ["eastWins", 0];
private _winningTeam = if (_westWins > _eastWins) then { west } else { east };

if (_currentSide != _winningTeam) exitWith { false };

private _ratings = profileNamespace getVariable ["WL2_playerRatings", createHashMap];
private _playerElo = _ratings getOrDefault [_uid, WL_RATING_STARTER];
if (_playerElo <= WL_RATING_STARTER) exitWith { false };

private _currentSideElo = 0;
private _otherSideElo = 0;
private _currentSidePlayersCount = 0;
private _otherSidePlayersCount = 0;
{
    private _playerRating = _ratings getOrDefault [getPlayerUID _x, WL_RATING_STARTER];

    if (side group _x == _currentSide) then {
        _currentSideElo = _currentSideElo + _playerRating;
        _currentSidePlayersCount = _currentSidePlayersCount + 1;
    } else {
        _otherSideElo = _otherSideElo + _playerRating;
        _otherSidePlayersCount = _otherSidePlayersCount + 1;
    };
} forEach allPlayers;

if (_currentSidePlayersCount == 0) exitWith { false };
if (_otherSidePlayersCount == 0) exitWith { false };

private _currentSideAverage = _currentSideElo / _currentSidePlayersCount;
private _otherSideAverage = _otherSideElo / _otherSidePlayersCount;

if (_currentSideAverage <= _otherSideAverage) exitWith { false };

if (_playerElo <= _currentSideAverage) exitWith { false };

true;