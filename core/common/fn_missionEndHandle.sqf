if !(isDedicated) then {
	{
		deleteMarkerLocal _x
	} forEach ["BIS_WL_targetEnemy", "BIS_WL_targetFriendly"];

	private _gameWinner = missionNamespace getVariable ["WL2_gameWinner", sideUnknown];

	private _startWait = serverTime;
	waitUntil {
		sleep 0.1;
		_gameWinner = missionNamespace getVariable ["WL2_gameWinner", sideUnknown];
		serverTime - _startWait > 5 || _gameWinner != sideUnknown;
	};

	// Store game data for replay
	private _drawIcons = missionNamespace getVariable ["WL2_drawIcons", []];
	private _drawEllipses = missionNamespace getVariable ["WL2_drawEllipses", []];
	private _drawSectorIcons = missionNamespace getVariable ["WL2_drawSectorIcons", []];
	profileNamespace setVariable ["WL2_drawIcons", toJSON _drawIcons];
	profileNamespace setVariable ["WL2_drawEllipses", toJSON _drawEllipses];
	profileNamespace setVariable ["WL2_drawSectorIcons", toJSON _drawSectorIcons];
	saveProfileNamespace;

	private _playerSide = BIS_WL_playerSide;
	private _victory = _gameWinner == _playerSide;
	private _status = if (_victory) then {"Victory"} else {"Defeat"};
	_status call WL2_fnc_announcer;

	private _debriefing = format ["BIS_WL%1%2", _status, _playerSide];
	[_debriefing, _victory] call BIS_fnc_endMission;
} else {
	sleep 15;
	endMission "End1";
};