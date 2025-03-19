player addAction [
	"<t color='#0000ff'>Rappel</t>",
	{
		0 spawn {
			private _rope = call WL2_fnc_rappelActionEligibility;
			if (isNull _rope) exitWith {};

			player setVariable ["WL2_rappelling", true];
			playSoundUI ["a3\sounds_f\air\sfx\sl_4hooksunlock.wss"];

			sleep 1;

			player switchMove "LadderRifleStatic";
			player allowDamage false;
			private _sound = playSoundUI ["a3\sounds_f\vehicles\air\noises\wind_open_int.wss", 0.5, 2, true];

			private _up = getPosASL player # 2 < 10;
			private _rappelTime = if (_up) then {
				5
			} else {
				3
			};
			private _boundingBox = boundingBoxReal _rope;

			private _modelPositionMax = _rope modelToWorldWorld (_boundingBox # 1);
			private _modelPositionMin = _rope modelToWorldWorld (_boundingBox # 0);
			_modelPositionMin set [2, (_modelPositionMin # 2) max 0];

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

			private _interval = 0;
			private _startTime = serverTime;

			while { alive player && _interval < _rappelTime } do {
				sleep 0.0001;
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

			stopSound _sound;
			player switchMove "NoActions";

			private _finalRelativePosition = if (_up) then {
				(_boundingBox # 1) vectorAdd [0, 2, 0];
			} else {
				private _ropeBottom = _boundingBox # 0;
				_ropeBottom set [2, (_ropeBottom # 2) max 0];
				_ropeBottom vectorAdd [0, -2, 0];
			};
			private _finalPosition = _rope modelToWorld _finalRelativePosition;
			player setVehiclePosition [_finalPosition, [], 0, "CAN_COLLIDE"];

            sleep 1;
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