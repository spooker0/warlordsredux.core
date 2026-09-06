#include "includes.inc"
params ["_gameWinner", "_isSurrender", "_isClient"];

private _base1 = missionNamespace getVariable ["WL2_base1", objNull];
private _base2 = missionNamespace getVariable ["WL2_base2", objNull];
private _base = if (west != _gameWinner) then {
	_base1
} else {
	_base2
};

if (_isClient) then {
	{
		deleteMarkerLocal _x
	} forEach ["BIS_WL_targetEnemy", "BIS_WL_targetFriendly"];

	// Store game data for replay
	private _drawIcons = missionNamespace getVariable ["WL2_drawIcons", []];
	private _drawEllipses = missionNamespace getVariable ["WL2_drawEllipses", []];
	private _drawSemiCircles = missionNamespace getVariable ["WL2_drawSemiCircles", []];
	private _drawRectangles = missionNamespace getVariable ["WL2_drawRectangles", []];
	private _drawPolygons = missionNamespace getVariable ["WL2_drawPolygons", []];
	private _drawSectorIcons = missionNamespace getVariable ["WL2_drawSectorIcons", []];
	missionProfileNamespace setVariable ["WL2_drawIcons", toJSON _drawIcons];
	missionProfileNamespace setVariable ["WL2_drawEllipses", toJSON _drawEllipses];
	missionProfileNamespace setVariable ["WL2_drawSemiCircles", toJSON _drawSemiCircles];
	missionProfileNamespace setVariable ["WL2_drawRectangles", toJSON _drawRectangles];
	missionProfileNamespace setVariable ["WL2_drawPolygons", toJSON _drawPolygons];
	missionProfileNamespace setVariable ["WL2_drawSectorIcons", toJSON _drawSectorIcons];
	saveMissionProfileNamespace;

	openMap false;

	BIS_WL_missionEnd = true;

	if (_gameWinner == independent) exitWith {
		"Victory" call WL2_fnc_announcer;
		uiSleep 15;
		["WL2_End_Timeout", true] call BIS_fnc_endMission;
	};

	private _playerSide = BIS_WL_playerSide;
	private _victory = _gameWinner == _playerSide;
	private _status = if (_victory) then {"Victory"} else {"Defeat"};
	private _surrender = if (_isSurrender) then {"Surrender"} else {"Normal"};
	_status call WL2_fnc_announcer;

	[_base] spawn WL2_fnc_bigExplosion;

	uiSleep 25;

	private _debriefing = format ["WL2_%1_%2_%3", _status, _playerSide, _surrender];
	[_debriefing, true] call BIS_fnc_endMission;

	while { true } do {
		uiSleep 0.1;
		showScoretable 0;
	};
} else {
	private _firstCaption = if (_gameWinner == independent) then {
		"INDEPENDENT FORCES CLAIM VICTORY IN ALTIS AFTER HEAVY CASUALTIES TO BOTH NATO AND CSAT FORCES"
	} else {
		private _natoLosses = [
			"PENTAGON REFUSES TO CONFIRM REPORTS OF %1 NATO CASUALTIES IN ALTIS",
			"DOVER AFB RECEIVES BODIES OF %1 FALLEN NATO TROOPS",
			"GENERAL MILLER TO BE REPLACED AFTER %1 NATO TROOPS KILLED IN ALTIS"
		];
		private _csatLosses = [
			"DEFENSE MINISTRY DENIES CLAIM %1 CSAT TROOPS KILLED IN ALTIS BATTLE",
			"PLANS TO RENEW MOBILIZATION RUMORED AFTER BATTLE KILLS %1 CSAT SOLDIERS",
			"SOCIAL MEDIA REPORTS CONFIRM MORE THAN %1 CSAT SOLDIERS KILLED IN ALTIS"
		];
		private _neutralLosses = [
			"MILLION MARCH IN BERLIN AND PARIS, DEMAND END TO ILLEGAL %2 OCCUPATION OF ALTIS AFTER %1 KILLED IN BATTLE",
			"REBELS DRAG BODIES OF %2 SOLDIERS THROUGH STREETS OF KAVALA AFTER MASSIVE BATTLE LEAVES %1 DEAD",
			"UNKNOWN NUMBER OF TROOPS CAPTURED AND MISSING AS %2 ADMITS %1 SOLDIERS CONFIRMED KIA"
		];

		private _losses = 0;
		private _scoreboardData = missionNamespace getVariable ["WL2_scoreboardData", createHashMap];
		{
			private _entry = _y;
			private _side = _entry getOrDefault ["sideEnd", independent];
			if (_side != _gameWinner) then {
				private _deaths = _entry getOrDefault ["deaths", 0];
				_losses = _losses + _deaths;
			};
		} forEach _scoreboardData;

		private _textPossibilities = switch (_gameWinner) do {
			case west: { _natoLosses + _neutralLosses };
			case east: { _csatLosses + _neutralLosses };
			default { [""] };
		};

		private _gameLoser = switch (_gameWinner) do {
			case west: { "CSAT" };
			case east: { "NATO" };
			default { "" };
		};
		private _selectedText = selectRandom _textPossibilities;
		format [_selectedText, _losses, _gameLoser];
	};

	missionNamespace setVariable ["WL2_endText", _firstCaption, true];

	uiSleep 35;
	endMission "End1";
};