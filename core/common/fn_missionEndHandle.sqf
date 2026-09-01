#include "includes.inc"
params ["_gameWinner", "_isSurrender", "_isClient"];
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

	private _base1 = missionNamespace getVariable ["WL2_base1", objNull];
	private _base2 = missionNamespace getVariable ["WL2_base2", objNull];
	private _base = if (west != _gameWinner) then {
		_base1
	} else {
		_base2
	};

	[_base] spawn {
		params ["_base"];
		private _camera = "camera" camCreate [0, 0, 0];
		_camera camCommit 0;
		_camera switchCamera "INTERNAL";

		private _basePos = _base modelToWorld [0, 0, 0];

		private _targetDistance = 2000;
		private _initialX = random 2000;
		if (random 1 < 0.5) then {
			_initialX = -1 * _initialX;
		};
		private _initialY = sqrt (_targetDistance ^ 2 - _initialX ^ 2);
		if (random 1 < 0.5) then {
			_initialY = -1 * _initialY;
		};

		private _initialVector = [_initialX, _initialY, 500];
		private _cameraPos = _base modelToWorld _initialVector;

		private _targetVectorDirAndUp = [_cameraPos, _basePos] call BIS_fnc_findLookAt;
		_camera setVectorDirAndUp _targetVectorDirAndUp;
		_camera setPosASL (AGLtoASL _cameraPos);

		_camera switchCamera "INTERNAL";

		[_basePos] spawn WL2_fnc_bigExplosion;
	};

	private _debriefing = format ["WL2_%1_%2_%3", _status, _playerSide, _surrender];

	private _debriefingTitle = toUpper getText (missionConfigFile >> "CfgDebriefing" >> _debriefing >> "title");
	private _debriefingSubtitle = toUpper getText (missionConfigFile >> "CfgDebriefing" >> _debriefing >> "subtitle");
	[
		parseText format ["<t size='2'>%1 - %2</t>", _debriefingTitle, _debriefingSubtitle],
		parseText toUpper "Altis evacuation in progress. Elevated radiation levels detected. Head to nearest emergency shelter."
	] spawn BIS_fnc_AAN;

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