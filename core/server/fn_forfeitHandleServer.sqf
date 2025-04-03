params ["_side"];

private _varName = format ["BIS_WL_forfeitVotingSince_%1", _side];

private _forfeiterNameVar = format ["BIS_WL_forfeitOrderedBy_%1", _side];
private _forfeiterName = missionNamespace getVariable [_forfeiterNameVar, "Someone"];
private _message = format ["%1 has initiated a vote to forfeit the game.", _forfeiterName];
{
	[[_side, "Base"], _message] remoteExec ["commandChat", owner _x];
} forEach (allPlayers select {side group _x == _side});

while { serverTime < ((missionNamespace getVariable [_varName, -1]) + 30) } do {
	sleep 0.25;

	private _warlords = allPlayers select {
		side group _x == _side &&
		!(_x getVariable ["BIS_WL_incomeBlocked", false])
	};
	private _limit = ceil ((count _warlords) / 2);
	private _votedYes = {
		_x getVariable ["BIS_WL_forfeitVote", -1] == 1
	} count _warlords;

	if (_votedYes >= _limit && serverTime >= 180) then {
		missionNamespace setVariable ["BIS_WL_ffTeam", _side, true];
		missionNamespace setVariable ["BIS_WL_missionEnd", true, true];

		0 spawn WL2_fnc_calculateEndResults;
		0 remoteExec ["WL2_fnc_missionEndHandle", 0];

		break;
	};
};

{
	if ((_x getVariable ["BIS_WL_forfeitVote", -1]) != -1) then {
		_x setVariable ["BIS_WL_forfeitVote", nil, [2, (owner _x)]];
	};
} forEach (allPlayers select {side group _x == _side});