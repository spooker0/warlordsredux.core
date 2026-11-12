#include "includes.inc"
params ["_className"];

private _minElo = WL_ASSET(_className, "minElo", 0);
if (_minElo <= 0) exitWith {
    [true, ""];
};

private _playerRating = player getVariable ["WL2_playerRating", WL_RATING_STARTER];
if (_playerRating < _minElo) exitWith {
    [false, format [localize "STR_WL_minEloRequired", _minElo]];
};

[true, ""];