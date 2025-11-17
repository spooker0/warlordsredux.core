#include "includes.inc"
player setVariable ["WL2_hasGrapple", 3];
player addAction [
	"<t color='#0000ff'>Grapple (3 uses)</t>",
	{
		params ["_target", "_caller", "_actionId", "_arguments"];

		private _grappleCount = player getVariable ["WL2_hasGrapple", 0];
		player setVariable ["WL2_hasGrapple", _grappleCount - 1];

		if (_grappleCount <= 1) then {
			player removeAction _actionId;
		} else {
			player setUserActionText [_actionId, format ["<t color='#0000ff'>Grapple (%1 uses)</t>", _grappleCount - 1]];
		};

		0 spawn {
			player setVariable ["WL2_rappelling", true];
			playSoundUI ["a3\sounds_f\air\sfx\sl_4hooksunlock.wss"];

			private _startPos = getPosASL player;
            private _intersections = lineIntersectsSurfaces [
                AGLToASL positionCameraToWorld [0, 0, 0],
                AGLToASL positionCameraToWorld [0, 0, 100],
                player,
                objNull,
                true,
                1,
                "FIRE",
                "",
                true
            ];
			private _hitPos = if (count _intersections == 0) then {
				_startPos;
			} else {
				_intersections select 0 select 0;
			};

            private _endPos = if (count _intersections == 0) then {
                _startPos;
            } else {
                private _newEndPos = +_hitPos;
                _newEndPos set [2, (_newEndPos # 2) - 1.5 - 1.5];
                _newEndPos;
            };
			private _endIsFlat = if (count _intersections == 0) then {
				true
			} else {
				private _normal = _intersections select 0 select 1;
				abs (_normal # 2) > 0.7
			};

			private _distanceToEnd = _endPos distance _startPos;

			private _dummyStart = createVehicle ["I_TargetSoldier", eyePos player, [], 0, "CAN_COLLIDE"];
			_dummyStart setPosASL (eyePos player);
			_dummyStart enableRopeAttach true;
			_dummyStart disableCollisionWith player;
			[_dummyStart] remoteExec ["WL2_fnc_hideObjectOnAll", 2];

			private _dummyEnd = createVehicle ["I_TargetSoldier", _hitPos, [], 0, "CAN_COLLIDE"];
			_dummyEnd setPosASL _hitPos;
			_dummyEnd enableRopeAttach true;
			_dummyEnd disableCollisionWith player;
			[_dummyEnd] remoteExec ["WL2_fnc_hideObjectOnAll", 2];

			private _cable = ropeCreate [_dummyStart, [0, 0, 0], _dummyEnd, [0, 0, 0], _distanceToEnd, ["", [0, 0, -1]], ["", [0, 0, -1]], "Rope", 1];
			uiSleep 1;

			[player, ["LadderRifleStatic"]] remoteExec ["switchMove", 0];
			player allowDamage false;

			private _sound = createSoundSourceLocal ["WLRopeTravelSound", player modelToWorld [0, 0, 0], [], 0];

			private _rappelTime = _distanceToEnd / 30;

			private _interval = 0;
			private _startTime = serverTime;

			while { alive player && _interval < _rappelTime } do {
				uiSleep 0.001;
				player setVelocityTransformation [
					_startPos,
					_endPos,
					[0, 0, 0],
					[0, 0, 0],
					[0, 0, 1],
					[0, 0, 1],
					[0, 0, 1],
					[0, 0, 1],
					_interval / _rappelTime,
                    [0, 0, -1.5]
				];
				_sound setPosATL (getPosATL player);
				_interval = serverTime - _startTime;
			};

            player setVelocity [0, 0, 0];
			deleteVehicle _sound;

			if (!_endIsFlat) then {
				uiSleep 0.2;

				private _vaultPositionStart = player modelToWorldWorld [0, 0, 0];
				private _vaultPositionBase = player modelToWorldWorld [0, 0, 4];
				private _vaultPositionEnd = player modelToWorldWorld [0, 2, 4];

				private _vaultIntersections1 = lineIntersectsSurfaces [
					_vaultPositionStart,
					_vaultPositionBase,
					player,
					objNull,
					true,
					1,
					"FIRE",
					"",
					true
				];

				private _vaultIntersections2 = lineIntersectsSurfaces [
					_vaultPositionBase,
					_vaultPositionEnd,
					player,
					objNull,
					true,
					1,
					"FIRE",
					"",
					true
				];

				if (count _vaultIntersections1 == 0 && count _vaultIntersections2 == 0) then {
					player setPosASL _vaultPositionEnd;
				} else {
					private _backwards = player modelToWorldWorld [0, -1, 0];
					player setPosASL _backwards;
				};
			} else {
				if (_startPos # 2 > _endPos # 2) then {
					player setVehiclePosition [player modelToWorld [0, 0, 0], [], 0, "NONE"];
				};
			};

			private _maxTimeInAir = serverTime + 5;
			waitUntil {
				uiSleep 0.1;
				isTouchingGround player || serverTime > _maxTimeInAir
			};

			[player, [""]] remoteExec ["switchMove", 0];
			player allowDamage true;
			player setVariable ["WL2_rappelling", false];

			uiSleep 0.5;
			ropeDestroy _cable;
			deleteVehicle _dummyStart;
			deleteVehicle _dummyEnd;
		};
	},
	[],
	100,
	false,
	true,
	"",
	"surfaceIsWater (getPosASL player)"
];