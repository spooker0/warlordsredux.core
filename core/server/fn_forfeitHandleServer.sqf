params ["_side"];

private _varName = format ["BIS_WL_forfeitVotingSince_%1", _side];

private _forfeiterNameVar = format ["BIS_WL_forfeitOrderedBy_%1", _side];
private _forfeiterName = missionNamespace getVariable [_forfeiterNameVar, "Someone"];
private _message = format ["%1 has initiated a vote to forfeit the game.", _forfeiterName];
{
	[[_side, "Base"], _message] remoteExec ["commandChat", owner _x];
} forEach (allPlayers select {side group _x == _side});

private _voteSucceeded = false;

while { serverTime < ((missionNamespace getVariable [_varName, -1]) + 30) } do {
	sleep 0.25;

	private _eligibleVoters = (allPlayers select {side group _x == _side}) select {
		!(_x getVariable ["WL2_afk", false])
	};
	private _limit = ceil ((count _eligibleVoters) / 2);
	private _votedYes = {
		_x getVariable ["BIS_WL_forfeitVote", -1] == 1
	} count _eligibleVoters;

	if (_votedYes >= _limit) then {
		_voteSucceeded = true;
		break;
	};
};

if (_voteSucceeded) then {
	missionNamespace setVariable ["BIS_WL_missionEnd", true, true];
	missionNamespace setVariable ["WL2_gameWinner", _side, true];

	0 spawn WL2_fnc_calculateEndResults;
	0 remoteExec ["WL2_fnc_missionEndHandle", 0];
} else {
	{
		private _owner = owner _x;
		if ((_x getVariable ["BIS_WL_forfeitVote", -1]) != -1) then {
			_x setVariable ["BIS_WL_forfeitVote", nil, [2, _owner]];
		};

		[[_side, "Base"], "Surrender vote failed."] remoteExec ["commandChat", _owner];
	} forEach (allPlayers select {side group _x == _side});
};