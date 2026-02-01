#include "includes.inc"
params ["_asset"];

private _actionId = _asset addAction [
	"<t color='#00ff00'>Clear Mines</t>",
	{
		params ["_asset", "_caller", "_actionID"];

        private _mineClearCharges = _asset getVariable ["WL2_mineClearCharges", 0];
        if (_mineClearCharges <= 0) exitWith {
            playSound "AddItemFailed";
            ["No mine clearing charges available!"] call WL2_fnc_smoothText;
        };
        _asset setVariable ["WL2_mineClearCharges", _mineClearCharges - 1, true];

        [_asset] spawn {
            params ["_asset"];

            private _dispenseSounds = [
                "a3\sounds_f_orange\arsenal\explosives\minedispenser\minedispenser_launch_01.wss",
                "a3\sounds_f_orange\arsenal\explosives\minedispenser\minedispenser_launch_02.wss",
                "a3\sounds_f_orange\arsenal\explosives\minedispenser\minedispenser_launch_03.wss",
                "a3\sounds_f_orange\arsenal\explosives\minedispenser\minedispenser_launch_04.wss"
            ];
            private _detonateSounds = [
                "a3\sounds_f\arsenal\explosives\grenades\explosion_gng_grenades_01.wss",
                "a3\sounds_f\arsenal\explosives\grenades\explosion_gng_grenades_02.wss",
                "a3\sounds_f\arsenal\explosives\grenades\explosion_gng_grenades_03.wss",
                "a3\sounds_f\arsenal\explosives\grenades\explosion_gng_grenades_04.wss"
            ];

            private _length = 500;
            private _step = 25;
            private _width = 50;
            private _direction = getDir _asset;

            playSound3D [selectRandom _dispenseSounds, _asset];
            playSound3D [selectRandom _dispenseSounds, _asset];

            private _mineClearOrigin = _asset modelToWorld [0, _length, 0];
            private _mineClearArea = [_mineClearOrigin, _width, _length, _direction, true];

            private _assetPos = getPosASL _asset;

            private _projectile = createVehicle ["SmokeShell", _asset modelToWorld [0, 0, 1], [], 0, "FLY"];
            _projectile setDir _direction;
            [_projectile, 10, 0] call BIS_fnc_setPitchBank;
            _projectile setVelocityModelSpace [0, 200, 0];

            [_asset modelToWorld [0, 0, 0], [
                ["DeminingExplosiveCircleDust", 0.6],
                ["SecondaryExp", 0.4],
                ["SecondarySmoke", 0.4],
                ["FX_MissileTrail_SAM", _projectile]
            ]] remoteExec ["WL2_fnc_particleEffect", 0];

            private _detonatePositions = [];
            for "_i" from _step to _length step _step do {
                private _bombPos = _asset modelToWorld [0, _i, 0];
                _bombPos set [2, 0];
                _detonatePositions pushBack _bombPos;
            };

            private _dummyStartPos = _asset modelToWorld [0, 5, 0];
            _dummyStartPos set [2, 0];
            private _dummyStart = createVehicle ["I_TargetSoldier", _dummyStartPos, [], 0, "CAN_COLLIDE"];
            _dummyStart enableRopeAttach true;

            private _dummyEndPos = _asset modelToWorld [0, 90, 0];
            _dummyEndPos set [2, 20];
            private _dummyEnd = createVehicle ["I_TargetSoldier", _dummyEndPos, [], 0, "CAN_COLLIDE"];
            _dummyEnd setPosASL (AGLtoASL _dummyEndPos);
            _dummyEnd enableRopeAttach true;

            private _cable = ropeCreate [_dummyStart, [0, 0, 0], _dummyEnd, [0, 0, 0], 100];

            private _detonateFx = [];
            private _jitter = 7;
            {
                private _bombPos = _x;

                private _effectPos = +_bombPos;
                _effectPos set [0, _effectPos # 0 + random _jitter - _jitter / 2];
                _effectPos set [1, _effectPos # 1 + random _jitter - _jitter / 2];

                [_effectPos, [
                    ["DeminingExplosiveCircleDust", 0.3],
                    ["SecondarySmoke", 0.2]
                ]] remoteExec ["WL2_fnc_particleEffect", 0];

                _detonateFx pushBack ["SecondaryExp", [random 0.6, _bombPos]];

                uiSleep (random 0.2);
            } forEach _detonatePositions;

            deleteVehicle _projectile;

            uiSleep 3;

            private _side = BIS_WL_playerSide;

            private _minesInArea = allMines inAreaArray _mineClearArea;

            private _enemyUnits = switch (_side) do {
                case west: { BIS_WL_eastOwnedVehicles + BIS_WL_guerOwnedVehicles };
                case east: { BIS_WL_westOwnedVehicles + BIS_WL_guerOwnedVehicles };
                case independent: { BIS_WL_westOwnedVehicles + BIS_WL_eastOwnedVehicles };
                default { [] };
            };

            private _enemyMineVehicles = _enemyUnits select {
                WL_ISUP(_x)
            } select {
                private _unitActualType = _x getVariable ["WL2_orderedClass", typeOf _x];
                WL_ASSET(_unitActualType, "smartMineAP", 0) > 0 || WL_ASSET(_unitActualType, "smartMineAT", 0) > 0
            };
            private _enemyMineVehiclesInArea = _enemyMineVehicles inAreaArray _mineClearArea;

            _minesInArea append _enemyMineVehiclesInArea;

            [player, "demine", _asset, _minesInArea] remoteExec ["WL2_fnc_handleClientRequest", 2];

            playSound3D [selectRandom _detonateSounds, objNull, false, _assetPos, 5];
            [_mineClearOrigin, _detonateFx] remoteExec ["WL2_fnc_particleEffect", 0];

            uiSleep 1;
            ropeDestroy _cable;

            deleteVehicle _dummyStart;
            deleteVehicle _dummyEnd;
        };
	},
	[],
	7,
	true,
	false,
	"",
	"driver _target == _this && _target getVariable ['WL2_mineClearCharges', 0] > 0",
	-98,
	false
];