#include "includes.inc"
params ["_gameWinner", "_isSurrender"];
if (!isDedicated) then {
	{
		deleteMarkerLocal _x
	} forEach ["BIS_WL_targetEnemy", "BIS_WL_targetFriendly"];

	// Store game data for replay
	private _drawIcons = missionNamespace getVariable ["WL2_drawIcons", []];
	private _drawEllipses = missionNamespace getVariable ["WL2_drawEllipses", []];
	private _drawRectangles = missionNamespace getVariable ["WL2_drawRectangles", []];
	private _drawSectorIcons = missionNamespace getVariable ["WL2_drawSectorIcons", []];
	profileNamespace setVariable ["WL2_drawIcons", toJSON _drawIcons];
	profileNamespace setVariable ["WL2_drawEllipses", toJSON _drawEllipses];
	profileNamespace setVariable ["WL2_drawRectangles", toJSON _drawRectangles];
	profileNamespace setVariable ["WL2_drawSectorIcons", toJSON _drawSectorIcons];
	saveProfileNamespace;

	openMap false;

	BIS_WL_missionEnd = true;
	private _display = uiNamespace getVariable ["RscWLScoreboardMenu", displayNull];
	if (isNull _display) then {
		0 spawn WL2_fnc_scoreboard;
	};

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
	private _base = if (_base1 getVariable ["BIS_WL_originalOwner", independent] != _gameWinner) then {
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
		private _cameraPos = _base modelToWorld [0, -400, 300];

		private _targetVectorDirAndUp = [_cameraPos, _basePos] call BIS_fnc_findLookAt;
		_camera setVectorDirAndUp _targetVectorDirAndUp;
		_camera setPosASL (AGLtoASL _cameraPos);

		_camera switchCamera "INTERNAL";

		private _endPos = _base modelToWorld [0, -200, 150];
		private _endTargetVectorDirAndUp = [_endPos, _basePos] call BIS_fnc_findLookAt;

		private _startTime = serverTime;
		private _interval = 0;

		while { alive _camera && _interval < 5 } do {
			uiSleep 0.001;
			_camera setVelocityTransformation [
				AGLtoASL _cameraPos,
				AGLtoASL _endPos,
				[0, 0, 0],
				[0, 0, 0],
				_targetVectorDirAndUp # 0,
				_endTargetVectorDirAndUp # 0,
				_targetVectorDirAndUp # 1,
				_endTargetVectorDirAndUp # 1,
				_interval / 5
			];
			_interval = serverTime - _startTime;
		};
	};

	uiSleep 15;

	private _debriefing = format ["WL2_%1_%2_%3", _status, _playerSide, _surrender];
	[_debriefing, true] call BIS_fnc_endMission;

	while { true } do {
		uiSleep 0.1;
		showScoretable 0;
	};
} else {
	private _base = if (_gameWinner == west) then {
		WL2_base2;
	} else {
		WL2_base1;
	};

	private _startTime = serverTime;
	private _startPos = _base modelToWorld [0, -400, 300];
	for "_i" from 1 to 5 do {
		for "_j" from 1 to 20 do {
			private _explosion = createVehicle ["R_80mm_HE", _startPos, [], 0, "CAN_COLLIDE"];

			private _targetPos = _base modelToWorld [random 400 - 200, random 400 - 200, 0];
			private _targetVectorDirAndUp = [_startPos, _targetPos] call BIS_fnc_findLookAt;
			_explosion setVectorDirAndUp _targetVectorDirAndUp;
			_explosion setVelocityModelSpace [0, 200, 0];

			uiSleep (random 0.1);
		};
		uiSleep (random 5);
	};
	private _timeElapsed = serverTime - _startTime;
	uiSleep (30 - _timeElapsed);

	endMission "End1";
};