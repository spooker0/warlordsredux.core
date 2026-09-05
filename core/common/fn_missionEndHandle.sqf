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

	private _debriefing = format ["WL2_%1_%2_%3", _status, _playerSide, _surrender];
	[_base, _debriefing] spawn WL2_fnc_bigExplosion;

	uiSleep 25;

	[_debriefing, true] call BIS_fnc_endMission;

	while { true } do {
		uiSleep 0.1;
		showScoretable 0;
	};
} else {
	uiSleep 35;
	endMission "End1";
};