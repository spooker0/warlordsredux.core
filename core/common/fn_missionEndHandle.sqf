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
	profileNamespace setVariable ["WL2_drawIcons", toJSON _drawIcons];
	profileNamespace setVariable ["WL2_drawEllipses", toJSON _drawEllipses];
	profileNamespace setVariable ["WL2_drawSemiCircles", toJSON _drawSemiCircles];
	profileNamespace setVariable ["WL2_drawRectangles", toJSON _drawRectangles];
	profileNamespace setVariable ["WL2_drawPolygons", toJSON _drawPolygons];
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

		private _targetDistance = 400;
		private _initialX = random 400;
		if (random 1 < 0.5) then {
			_initialX = -1 * _initialX;
		};
		private _initialY = sqrt (_targetDistance ^ 2 - _initialX ^ 2);
		if (random 1 < 0.5) then {
			_initialY = -1 * _initialY;
		};

		private _initialVector = [_initialX, _initialY, 300];
		private _cameraPos = _base modelToWorld _initialVector;

		private _targetVectorDirAndUp = [_cameraPos, _basePos] call BIS_fnc_findLookAt;
		_camera setVectorDirAndUp _targetVectorDirAndUp;
		_camera setPosASL (AGLtoASL _cameraPos);

		_camera switchCamera "INTERNAL";

		private _finalVector = _initialVector vectorMultiply 0.5;
		private _endPos = _base modelToWorld _finalVector;
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

	[_base] spawn {
		params ["_base"];
		playSoundUI ["a3\sounds_f\ambient\battlefield\battlefield_explosions1.wss", 2];

		private _detonateSounds = [
			"a3\sounds_f\arsenal\explosives\shells\shellheavyb_distexp.wss",
			"a3\sounds_f\arsenal\explosives\shells\shellheavyb_distexp_01.wss",
			"a3\sounds_f\arsenal\explosives\shells\shellheavyb_distexp_02.wss",
			"a3\sounds_f\arsenal\explosives\shells\shellheavyb_distexp_03.wss",
			"a3\sounds_f\arsenal\explosives\shells\shelllighta_distexp_01.wss",
			"a3\sounds_f\arsenal\explosives\shells\shelllighta_distexp_02.wss",
			"a3\sounds_f\arsenal\explosives\shells\shelllighta_distexp_03.wss",
			"a3\sounds_f\arsenal\explosives\shells\shellmedium_distexp_01.wss",
			"a3\sounds_f\arsenal\explosives\shells\shellmedium_distexp_02.wss",
			"a3\sounds_f\arsenal\explosives\shells\shellmedium_distexp_03.wss"
		];

		private _startPos = _base modelToWorldWorld [500, 500, 500];
		private _targetBase = -300;
		while { alive _base } do {
			private _targetPos = _base modelToWorld [_targetBase + (random 20 - 10), random 300 - 150, 0];
			_targetPos set [2, 1];

			[_targetPos, [
				["DeminingExplosiveCircleDust", 1],
				["BombExp1", random 0.8],
				["BombSmk1", random 0.2],
				["SecondaryExp", 0.5],
				["SecondarySmoke", 2]
			]] spawn WL2_fnc_particleEffect;

			playSound3D [
				selectRandom _detonateSounds,
				objNull,
				false,
				AGLtoASL _targetPos,
				5,
				1,
				0,
				0,
				true
			];

			_targetBase = _targetBase + 5;

			if (_targetBase > 300) then {
				_targetBase = -300;
			};
			uiSleep (random 0.2);
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
	uiSleep 30;
	endMission "End1";
};