#include "includes.inc"
private _scoreboardData = missionNamespace getVariable ["WL2_scoreboardData", createHashMap];
private _scoreboardResults = [];

private _playerContribution = missionNamespace getVariable ["WL_PlayerSquadContribution", createHashMap];
{
    private _playerUid = _x;
    private _entry = _y;

    if (_playerUid == "") then {
        continue;
    };
    _entry set ["uid", _playerUid];

    private _unit = [_playerUid] call BIS_fnc_getUnitByUid;
    private _unitName = [_unit] call BIS_fnc_getName;

    if (_unitName != "") then {
        _entry set ["name", _unitName];
    };

    private _playerSide = side group _unit;
    _entry set ["side", [_playerSide] call WL2_fnc_sideToFaction];

    _entry set ["points", _playerContribution getOrDefault [_playerUid, 0]];

    _scoreboardResults pushBack _entry;
} forEach _scoreboardData;

missionNamespace setVariable ["WL2_scoreboardResults", _scoreboardResults, [2, remoteExecutedOwner]];