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

private _duration = WL_DURATION_MISSION - (estimatedEndServerTime - serverTime);
_duration = WL_RATING_DURMAX min _duration;
private _timeMultiplier = WL_RATING_DURBASE / (_duration + WL_RATING_DURBASE);

private _westWinFactor = if (_gameWinner == west) then { 1 } else { 0 };

private _deltaWest = WL_RATING_KFACTOR * _timeMultiplier * (_westWinFactor - _expectedWinWest);
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