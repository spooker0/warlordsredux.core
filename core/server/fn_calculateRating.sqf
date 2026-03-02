#include "includes.inc"
params ["_gameWinner"];

private _ratings = profileNamespace getVariable ["WL2_playerRatings", createHashMap];

private _playerList = serverNamespace getVariable ["playerList", createHashMap];

private _westRating = 0;
private _eastRating = 0;
private _westCount = 0;
private _eastCount = 0;

{
    private _playerUid = _x;
    private _team = _y;

    private _playerRating = _ratings getOrDefault [_playerUid, WL_RATING_STARTER];

    if (_team == west) then {
        _westRating = _westRating + _playerRating;
        _westCount = _westCount + 1;
    };
    if (_team == east) then {
        _eastRating = _eastRating + _playerRating;
        _eastCount = _eastCount + 1;
    };
} forEach _playerList;

if (_westCount == 0) exitWith {};
if (_eastCount == 0) exitWith {};

private _westAverage = _westRating / _westCount;
private _eastAverage = _eastRating / _eastCount;

private _differenceWest = _westAverage - _eastAverage;
private _expectedWinWest = 1 / (1 + (10 ^ (-_differenceWest / WL_RATING_ELOSCALE)));

private _elapsedSeconds = WL_DURATION_MISSION - (estimatedEndServerTime - serverTime);
_elapsedSeconds = 0 max _elapsedSeconds;
_elapsedSeconds = WL_DURATION_MISSION min _elapsedSeconds;

private _rawTimeFactor = 1 - (_elapsedSeconds / WL_DURATION_MISSION);

private _timeWindowSeconds = WL_DURATION_MISSION - WL_RATING_DURMIN;

private _effectiveElapsedSeconds = _elapsedSeconds max WL_RATING_DURMIN;
_effectiveElapsedSeconds = WL_DURATION_MISSION min _effectiveElapsedSeconds;
private _graceTimeFactor = 1 - ((_effectiveElapsedSeconds - WL_RATING_DURMIN) / _timeWindowSeconds);

private _westIsFavorite = _expectedWinWest >= 0.5;
private _eastIsFavorite = !_westIsFavorite;

private _actualScoreWest = 0.5;

if (_gameWinner == west) then {
    private _timeFactor = if (_westIsFavorite) then { _graceTimeFactor } else { _rawTimeFactor };
    _actualScoreWest = 0.5 + 0.5 * _timeFactor;
};

if (_gameWinner == east) then {
    private _timeFactor = if (_eastIsFavorite) then { _graceTimeFactor } else { _rawTimeFactor };
    _actualScoreWest = 0.5 - 0.5 * _timeFactor;
};

private _deltaWest = WL_RATING_KFACTOR * (_actualScoreWest - _expectedWinWest);
_deltaWest = round _deltaWest;

{
    private _playerUid = _x;
    private _team = _y;

    private _playerRating = _ratings getOrDefault [_playerUid, WL_RATING_STARTER];

    if (_team == west) then {
        private _newRating = _playerRating + _deltaWest;
        _ratings set [_playerUid, _newRating];
    };
    if (_team == east) then {
        private _newRating = _playerRating - _deltaWest;
        _ratings set [_playerUid, _newRating];
    };
} forEach _playerList;

profileNamespace setVariable ["WL2_playerRatings", _ratings];
saveProfileNamespace;