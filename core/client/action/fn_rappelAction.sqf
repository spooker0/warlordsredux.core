#include "includes.inc"
player addAction [
	"<t color='#0000ff'>Rappel</t>",
	{
		0 spawn {
			private _rope = call WL2_fnc_rappelActionEligibility;
			if (isNull _rope) exitWith {};

			player setVariable ["WL2_rappelling", true];
			playSoundUI ["a3\sounds_f\air\sfx\sl_4hooksunlock.wss"];

			uiSleep 1;

			[player, ["LadderRifleStatic"]] remoteExec ["switchMove", 0];
			player allowDamage false;

			private _boundingBox = boundingBoxReal _rope;
			private _modelPositionMax = _rope modelToWorldWorld (_boundingBox # 1);
			private _modelPositionMin = _rope modelToWorldWorld (_boundingBox # 0);
			private _ropeMinLevel = _rope getVariable ["WL2_rappelRopeMinLevel", 0];
			_modelPositionMin set [2, (_modelPositionMin # 2) max _ropeMinLevel];

			private _playerASL = getPosASL player;
			private _up = _playerASL distance _modelPositionMin < _playerASL distance _modelPositionMax;
			private _startPos = if (_up) then {
				_modelPositionMin
			} else {
				_modelPositionMax
			};
			private _endPos = if (_up) then {
				_modelPositionMax
			} else {
				_modelPositionMin
			};
			private _ropeLength = _startPos distance _endPos;
			private _rappelTime = if (_up) then {
				_ropeLength / 5
			} else {
				_ropeLength / 10
			};

			private _interval = 0;
			private _startTime = serverTime;

			while { alive player && _interval < _rappelTime } do {
				uiSleep 0.0001;
				player setVelocityTransformation [
					_startPos,
					_endPos,
					[0, 0, 0],
					[0, 0, 0],
					[0, 0, 1],
					[0, 0, 1],
					[0, 0, 1],
					[0, 0, 1],
					_interval / _rappelTime
				];
				_interval = serverTime - _startTime;
			};

			[player, [""]] remoteExec ["switchMove", 0];

			private _finalRelativePosition = if (_up) then {
				(_boundingBox # 1) vectorAdd [0, 2, 0];
			} else {
				(_boundingBox # 0) vectorAdd [0, -2, 0];
			};
			private _finalPosition = _rope modelToWorld _finalRelativePosition;
			_finalPosition set [2, _finalPosition # 2 max _ropeMinLevel];
			player setVehiclePosition [_finalPosition, [], 0, "CAN_COLLIDE"];

            uiSleep 1;
			player allowDamage true;
			player setVariable ["WL2_rappelling", false];
		};
	},
	[],
	100,
	false,
	true,
	"",
	"!isNull (call WL2_fnc_rappelActionEligibility)"
];