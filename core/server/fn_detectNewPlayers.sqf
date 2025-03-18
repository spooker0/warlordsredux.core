private _previousAIMax = -1;
while { !BIS_WL_missionEnd } do {
	private _allPlayers = call BIS_fnc_listPlayers;
	private _newPlayers = _allPlayers select {
		(!isNull _x) && !(_x getVariable ["WL2_playerSetupStarted", false])
	};

	{
		_x spawn WL2_fnc_setupNewPlayer;
	} forEach _newPlayers;

	private _thresholds = [8, 15, 20, 30, 40];

	private _players = (playersNumber west) + (playersNumber east);
	private _value = 1;
	{
		if (_players < _x) then {
			_value = _value + 1;
		};
	} forEach _thresholds;
	if (_value != _previousAIMax) then {
		missionNamespace setVariable ["BIS_WL_maxSubordinates_west", _value, true];
		missionNamespace setVariable ["BIS_WL_maxSubordinates_east", _value, true];
	};
	_previousAIMax = _value;

#if WL_FACTION_THREE_ENABLED
	missionNamespace setVariable ["BIS_WL_maxSubordinates_guer", 12, true];
#endif

	uiSleep 1;
};