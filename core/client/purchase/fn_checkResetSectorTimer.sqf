#include "includes.inc"
private _sectorSelectedTimestampVar = format ["BIS_WL_sectorSelectedTimestamp_%1", BIS_WL_playerSide];
private _targetResetVotingVar = format ["BIS_WL_targetResetVotingSince_%1", BIS_WL_playerSide];

private _sectorSelectedTimestamp = missionNamespace getVariable [_sectorSelectedTimestampVar, 0];
private _targetResetVoting = missionNamespace getVariable [_targetResetVotingVar, 0];

private _resetSectorTimerEnd = _sectorSelectedTimestamp + WL_COOLDOWN_SECTORRESET;
if (serverTime < _resetSectorTimerEnd) exitWith {
    private _timeLeft = [_resetSectorTimerEnd - serverTime, "MM:SS"] call BIS_fnc_secondsToString;
    [false, format ["Reset Sector Timer: %1", _timeLeft]];
};

[true, ""];