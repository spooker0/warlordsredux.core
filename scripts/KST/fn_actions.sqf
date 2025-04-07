#include "..\..\core\warlords_constants.inc"

params ["_kills"];

#if WL_EASTER_EGG

if !(missionNamespace getVariable ["WL_easterEggOverride", false]) exitWith {};

if (_kills == 3) then {
	player addAction [
		"<t color='#ff0000'>Call UAV</t>",
		{
			params ["_target", "_caller", "_actionId"];
			player removeAction _actionId;

			private _uavPosition = getPosATL player;
			_uavPosition set [2, 500];
			private _uav = createVehicle ["C_UAV_06_F", _uavPosition, [], 0, "FLY"];
			_uav attachTo [player];

			_uav setVariable ["WL_scannerOn", true];
			_uav setVariable ["BIS_WL_ownerAssetSide", BIS_WL_playerSide];
			_uav allowDamage false;
			player setVariable ["WL_hmdOverride", 2];

			private _fuel = 60;
			private _startTime = serverTime;
			waitUntil {
				sleep 0.2;
				[_uav, -1, false, 1, 2000] call WL2_fnc_scanner;
				hintSilent format ["UAV - Fuel: %1%%", round (100 * (_fuel - (serverTime - _startTime)) / _fuel)];
				!alive player || serverTime - _startTime > _fuel
			};
			hintSilent "";

			player setVariable ["WL_hmdOverride", -1];
			_uav setVariable ["WL_scannerOn", false];
			deleteVehicle _uav;
		},
		[],
		150
	];
};


if (_kills == 5) then {
	player addAction [
		"<t color='#ff0000'>Predator Missile</t>",
		{
			params ["_target", "_caller", "_actionId"];
			player removeAction _actionId;

			setViewDistance 12000;
			setPiPViewDistance 12000;

			private _missilePos = getPosASL player;
			_missilePos set [2, 2000];
			private _missile = createVehicle ["ammo_Missile_Cruise_01", _missilePos, [], 0, "NONE"];
			_missile setDir (direction player);

			private _uav = createVehicle ["C_UAV_06_F", getPosATL _missile, [], 0, "FLY"];
			_uav attachTo [_missile, [0, 0, 100]];
			_uav setVariable ["WL_scannerOn", true];
			_uav setVariable ["BIS_WL_ownerAssetSide", BIS_WL_playerSide];
			_uav allowDamage false;
			player setVariable ["WL_hmdOverride", 2];

			"reticle" cutRsc ["RscTitleDisplayEmpty", "PLAIN"];
			private _display = uiNamespace getVariable ["RscTitleDisplayEmpty", displayNull];
			private _reticle = _display ctrlCreate ["RscPicture", -1];
			_reticle ctrlSetPosition [1 / 8, 0, 3 / 4, 1];
			_reticle ctrlSetText "\a3\weapons_f\Reticle\data\Optics_Gunner_APC_03_N_CA.paa";
			_reticle ctrlCommit 0;

			private _fuelDisplay = _display ctrlCreate ["RscStructuredText", -1];
			_fuelDisplay ctrlSetPosition [0, 0, 1, 0.2];
			_fuelDisplay ctrlSetTextColor [1, 1, 1, 1];
			_fuelDisplay ctrlCommit 0;

			private _instructionsDisplay = _display ctrlCreate ["RscStructuredText", -1];
			_instructionsDisplay ctrlSetPosition [0.7, 0.9, 0.5, 0.2];
			_instructionsDisplay ctrlSetTextColor [1, 1, 1, 1];
			_instructionsDisplay ctrlSetStructuredText parseText format [
				"<t align='left' size='1.2'>[%1] Boost<br/>[%2] Thermal Vision</t>",
				(actionKeysNames "defaultAction") regexReplace ["""", ""],
				(actionKeysNames "nightVision") regexReplace ["""", ""]
			];
			_instructionsDisplay ctrlCommit 0;

			playSoundUI ["a3\dubbing_f_heli\mp_groundsupport\70_tacticalstrikeinbound\mp_groundsupport_70_tacticalstrikeinbound_bhq_0.ogg", 3, 1, true];

			[_missile] spawn {
				params ["_missile"];
				private _sound = -1;
				while { alive _missile } do {
					_sound = playSoundUI ["A3\Sounds_F\weapons\Rockets\rocket_fly_2.wss", 3, 1, true];
					sleep ((soundParams _sound) # 2);
				};
				stopSound _sound;
			};

			[_missile] spawn {
				params ["_projectile"];
				private _yaw = getDir _projectile;
				private _pitch = -80;
				private _startTime = serverTime;
				private _fuel = 60;

				private _nightVision = false;
				private _boosted = false;
				while { alive _projectile } do {
					private _pitchInput = inputAction "AimHeadUp" - inputAction "AimHeadDown";
					private _yawInput = inputAction "AimHeadLeft" - inputAction "AimHeadRight";
					_pitchInput = _pitchInput * 0.1;
					_yawInput = _yawInput * 0.1;
					_yaw = _yaw - _yawInput;
					_pitch = _pitch + _pitchInput;
					_pitch = 89 min (_pitch max -80);

					private _cosPitch = cos _pitch;
					private _sinPitch = sin _pitch;
					private _cosYaw   = cos _yaw;
					private _sinYaw   = sin _yaw;

					private _forward = [
						_cosPitch * _sinYaw,
						_cosPitch * _cosYaw,
						_sinPitch
					];

					private _right = _forward vectorCrossProduct [0, 0, 1];
					_right = vectorNormalized _right;

					private _up = _right vectorCrossProduct _forward;
					_up = vectorNormalized _up;

					_projectile setVectorDirAndUp [_forward, _up];

					if (inputAction "defaultAction" > 0) then {
						_boosted = true;
					};
					if (_boosted) then {
						_projectile setVelocityModelSpace [0, 1500, 0];
					} else {
						_projectile setVelocityModelSpace [0, 500, 0];
					};

					if (inputAction "nightVision" > 0) then {
						waitUntil {
							inputAction "nightVision" == 0
						};
						_nightVision = !_nightVision;
					};
					if (_nightVision) then {
						true setCamUseTI 2;
					} else {
						false setCamUseTI 2;
					};

					sleep 0.001;
				};
			};

			[_missile, player] remoteExec ["KST_fnc_setParent", 2];

			_missile switchCamera "INTERNAL";
			player remoteControl _missile;

			showHUD [true, true, true, true, true, true, true, true, true, true, true];

			_uav setVariable ["WL_scannerOn", true];
			private _startTime = serverTime;
			private _fuel = 60;
			waitUntil {
				sleep 0.2;
				[_uav, -1, false, 1, 8000] call WL2_fnc_scanner;
				_fuelDisplay ctrlSetStructuredText parseText format ["<t align='center' size='2'>Fuel: %1%%</t>", round (100 * (_fuel - (serverTime - _startTime)) / _fuel)];
				!alive _missile || serverTime - _startTime > _fuel
			};
			if (alive _missile) then {
				triggerAmmo _missile;
			};

			sleep 3;
			switchCamera player;
			player remoteControl objNull;

			false setCamUseTI 2;

			"reticle" cutText ["", "PLAIN"];

			player setVariable ["WL_hmdOverride", -1];
			_uav setVariable ["WL_scannerOn", false];
			deleteVehicle _uav;

			[] call MENU_fnc_updateViewDistance;
		},
		[],
		150
	];
};

if (_kills == 7) then {
	player addAction [
		"<t color='#ff0000'>Chopper Gunner</t>",
		{
			params ["_target", "_caller", "_actionId"];
			player removeAction _actionId;

			private _chopperPos = getPosATL player;
			_chopperPos set [2, 600];
			private _chopper = createVehicle ["B_Heli_Attack_01_F", _chopperPos, [], 0, "FLY"];
			_chopper setPosASL _chopperPos;
			(group player) createVehicleCrew _chopper;
			_chopper setDir (direction player);
			_chopper flyInHeight [500, true];

			_chopper removeWeapon "gatling_20mm";
			_chopper addMagazineTurret ["60Rnd_40mm_GPR_Tracer_Red_shells", [0]];
			_chopper addWeaponTurret ["autocannon_40mm_VTOL_01", [0]];
			_chopper setVariable ["BIS_WL_ownerAsset", getPlayerUID player];

			"reticle" cutRsc ["RscTitleDisplayEmpty", "PLAIN"];
			private _display = uiNamespace getVariable ["RscTitleDisplayEmpty", displayNull];
			private _fuelDisplay = _display ctrlCreate ["RscStructuredText", -1];
			_fuelDisplay ctrlSetPosition [0, 0, 1, 0.2];
			_fuelDisplay ctrlSetTextColor [1, 1, 1, 1];
			_fuelDisplay ctrlCommit 0;

			private _instructionsDisplay = _display ctrlCreate ["RscStructuredText", -1];
			_instructionsDisplay ctrlSetPosition [0.7, 0.9, 0.5, 0.4];
			_instructionsDisplay ctrlSetTextColor [1, 1, 1, 1];
			_instructionsDisplay ctrlSetStructuredText parseText format [
				"<t align='left' size='1.2'>[%1/%2] Forward/Backward<br/>[%3/%4] Strafe<br/>[%5/%6] Turn<br/>[%7] Fire<br/>[%8] Missile</t>",
				(actionKeysNames ["MoveForward", 1, "Combo"]) regexReplace ["""", ""],
				(actionKeysNames ["MoveBack", 1, "Combo"]) regexReplace ["""", ""],
				(actionKeysNames ["LeanLeft", 1, "Combo"]) regexReplace ["""", ""],
				(actionKeysNames ["LeanRight", 1, "Combo"]) regexReplace ["""", ""],
				(actionKeysNames ["TurnLeft", 1, "Combo"]) regexReplace ["""", ""],
				(actionKeysNames ["TurnRight", 1, "Combo"]) regexReplace ["""", ""],
				(actionKeysNames ["defaultAction", 1, "Combo"]) regexReplace ["""", ""],
				(actionKeysNames ["throw", 1, "Combo"]) regexReplace ["""", ""]
			];
			_instructionsDisplay ctrlCommit 0;

			_chopper addEventHandler ["Fired", {
				params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_gunner"];
				private _shotIterator = _unit getVariable ["WL_shotIterator", 0];
				private _reloadSpeed = if (_shotIterator % 2 == 0) then {
					0.35;
				} else {
					0.7;
				};
				_unit setWeaponReloadingTime [gunner _unit, currentMuzzle gunner _unit, _reloadSpeed];
				_unit setMagazineTurretAmmo ["60Rnd_40mm_GPR_Tracer_Red_shells", 60, [0]];

				deleteVehicle _projectile;

				_unit setVariable ["WL_shotIterator", _shotIterator + 1];
				private _intersections = lineIntersectsSurfaces [
					getPosASL _gunner,
					getPosASL _gunner vectorAdd ((screenToWorldDirection [0.5, 0.5]) vectorMultiply 10000),
					_unit,
					_gunner,
					true,
					1,
					"FIRE",
					"",
					true
				];

				if (count _intersections > 0) then {
					private _pos = (_intersections # 0) # 0;
					[_pos, player] remoteExec ["KST_fnc_explode", 2];
				};
			}];

			_chopper removeWeapon "missiles_DAGR";
			_chopper removeWeapon "missiles_ASRAAM";
			_chopper removeWeapon "Laserdesignator_mounted";

			_chopper setVariable ["WL_missiles", 12];

			private _gunnerUnit = gunner _chopper;
			_gunnerUnit setVariable ["BIS_WL_ownerAsset", getPlayerUID player];
			playSoundUI ["a3\dubbing_f_heli\mp_groundsupport\50_cas\mp_groundsupport_50_cas_bhq_0.ogg", 3, 1, true];
			sleep 3;
			switchCamera _gunnerUnit;
			player remoteControl _gunnerUnit;
			deleteVehicle (driver _chopper);

			[_chopper] spawn {
				params ["_chopper"];
				while { alive _chopper } do {
					_chopper setVectorUp [0, 0, 1];

					private _directionInput = inputAction "TurnRight" - inputAction "TurnLeft";
					_chopper setDir (direction _chopper + _directionInput * 0.3);

					private _forwardInput = inputAction "MoveForward" - inputAction "MoveBack";
					private _lateralInput = inputAction "LeanRight" - inputAction "LeanLeft";
					private _newPos = _chopper modelToWorldWorld [_lateralInput, _forwardInput, 0];
					_newPos set [2, 600];
					_chopper setPosASL _newPos;
					sleep 0.001;
				};
			};

			[_chopper] spawn {
				params ["_chopper"];
				private _gunner = gunner _chopper;
				while { alive _chopper } do {
					private _missileRemaining = _chopper getVariable ["WL_missiles", 0];
					if (inputAction "throw" > 0 && _missileRemaining > 0) then {
						waitUntil {
							inputAction "throw" == 0
						};

						private _intersections = lineIntersectsSurfaces [
							getPosASL _gunner,
							getPosASL _gunner vectorAdd ((screenToWorldDirection [0.5, 0.5]) vectorMultiply 10000),
							_chopper,
							_gunner,
							true,
							1,
							"FIRE",
							"",
							true
						];

						if (count _intersections > 0) then {
							private _startPos = getPosASL _gunner;
							private _endPos = (_intersections # 0) # 0;
							[_startPos, cursorTarget, _endPos, player] remoteExec ["KST_fnc_rocket", 2];
							_chopper setVariable ["WL_missiles", _missileRemaining - 1];
							playSoundUI ["a3\sounds_f\weapons\rockets\new_rocket_3.wss", 2, 1, true];
						};
					};
					sleep 0.001;
				};
			};

			sleep 3;
			_gunnerUnit switchCamera "GUNNER";

			private _startTime = serverTime;
			private _fuel = 60;

			_chopper setVariable ["WL_scannerOn", true];
			waitUntil {
				sleep 0.2;
				player setVariable ["WL_hmdOverride", 2];
				_gunnerUnit selectWeapon ["autocannon_40mm_VTOL_01", "HE", "player"];
				[_chopper, -1, false, 1, 4000] call WL2_fnc_scanner;
				_fuelDisplay ctrlSetStructuredText parseText format [
					"<t align='center' size='2'>Fuel: %1%%<br/>Missiles: %2</t>",
					round (100 * (_fuel - (serverTime - _startTime)) / _fuel),
					_chopper getVariable ["WL_missiles", 0]
				];
				remoteControlled _gunnerUnit != player || !alive _chopper || !alive _gunnerUnit || serverTime - _startTime > _fuel
			};

			{
				deleteVehicle _x;
			} forEach (crew _chopper);
			deleteVehicle _chopper;

			"reticle" cutText ["", "PLAIN"];

			player setVariable ["WL_hmdOverride", -1];
			switchCamera player;
			player remoteControl objNull;
		},
		[],
		150
	];
};
#endif