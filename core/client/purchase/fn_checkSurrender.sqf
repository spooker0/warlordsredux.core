#include "includes.inc"
private _surrenderTime = 60 * 60 * 2;
private _timeSinceStart = WL_DURATION_MISSION - (estimatedEndServerTime - serverTime);
if (_timeSinceStart < _surrenderTime) exitWith {
	[false, format ["Surrender voting timer: %1", [_surrenderTime - _timeSinceStart, "MM:SS"] call BIS_fnc_secondsToString]];
};

// private _countSide = playersNumber BIS_WL_playerSide;
// private _enemySide = playersNumber BIS_WL_enemySide;

// if (_countSide < 10) exitWith {
// 	[false, format ["%1/10 Players", _countSide]];
// };
// if (_countSide < (_enemySide - 5)) exitWith {
// 	[true, ""];
// };

private _forfeitVotingVar = format ["BIS_WL_forfeitVotingSince_%1", BIS_WL_playerSide];
private _forfeitVoting = missionNamespace getVariable [_forfeitVotingVar, 0];
private _forfeitVotingTimer = _forfeitVoting + 60;
if (serverTime < _forfeitVotingTimer) exitWith {
	private _timeLeft = [_forfeitVotingTimer - serverTime, "MM:SS"] call BIS_fnc_secondsToString;
	[false, format ["Surrender voting timer: %1", _timeLeft]];
};

[true, ""];