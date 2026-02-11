#include "includes.inc"
params ["_player"];
private _ratings = profileNamespace getVariable ["WL2_playerRatings", createHashMap];
private _playerRating = _ratings getOrDefault [getPlayerUID _player, WL_RATING_STARTER];
[_player, _playerRating] remoteExec ["WL2_fnc_showRating", 0];