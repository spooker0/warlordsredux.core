#include "includes.inc"
params ["_asset"];

private _actionId = _asset addAction [
	"<t color='#00ff00'>Launch Line Charge</t>",
	{
		params ["_asset", "_caller", "_actionID"];

        private _mineClearCharges = _asset getVariable ["WL2_mineClearCharges", 0];
        if (_mineClearCharges <= 0) exitWith {
            playSound "AddItemFailed";
            ["No mine clearing charges available!"] call WL2_fnc_smoothText;
        };

        private _isFirstShot = WL_UNIT(_asset, "mineClear", 0) == _mineClearCharges;
        _asset setVariable ["WL2_mineClearCharges", _mineClearCharges - 1, true];

        [_asset, _isFirstShot] spawn {
            params ["_asset", "_isFirstShot"];

            private _dispenseSounds = [
                "a3\sounds_f\weapons\mortar\mortar_01.wss",
                "a3\sounds_f\weapons\mortar\mortar_02.wss",
                "a3\sounds_f\weapons\mortar\mortar_06.wss",
                "a3\sounds_f\weapons\mortar\mortar_07.wss"
            ];

            private _length = 500;
            private _step = 25;
            private _width = 50;
            private _direction = getDir _asset;

            playSound3D [selectRandom _dispenseSounds, _asset, false, getPosASL _asset, 5];

            private _mineClearOrigin = _asset modelToWorld [0, _length, 0];
            private _mineClearArea = [_mineClearOrigin, _width, _length, _direction, true];

            private _assetPos = getPosASL _asset;

            private _projectile = createVehicle ["GrenadeHand", _asset modelToWorld [0, 0, 1], [], 0, "FLY"];
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
            private _lineCharges = [];
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

                _detonateFx pushBack ["ImpactSparksSabot1", [random 0.3, _effectPos]];
                _detonateFx pushBack ["SecondaryExp", [random 0.6, _effectPos]];

                if (random 1 > 0.5) then {
                    private _lineCharge = createVehicle ["BombDemine_01_SubAmmo_F", _effectPos, [], 0, "CAN_COLLIDE"];
                    _lineCharge enableSimulation false;
                    [_lineCharge, [player, player]] remoteExec ["setShotParents", 2];
                    _lineCharges pushBack _lineCharge;
                };

                uiSleep (random 0.2);
            } forEach _detonatePositions;

            deleteVehicle _projectile;

            uiSleep 4.5;

            if (_isFirstShot) then {
                playSoundUI ["a3\dubbing_f_epa\a_m01\x20_detonate_casualties\a_m01_x20_detonate_casualties_med_0.ogg", 2];
            };

            uiSleep 1.5;

            [_mineClearOrigin, _detonateFx] remoteExec ["WL2_fnc_particleEffect", 0];
            {
                _x enableSimulation true;
                triggerAmmo _x;
                uiSleep (random 0.2);
            } forEach _lineCharges;

            private _side = BIS_WL_playerSide;

            private _minesInArea = allMines inAreaArray _mineClearArea;

            private _allUnits = (BIS_WL_westOwnedVehicles + BIS_WL_eastOwnedVehicles + BIS_WL_guerOwnedVehicles) select {
                WL_ISUP(_x)
            };
            private _allUnitsInArea = _allUnits inAreaArray _mineClearArea;

            private _mineEquipInArea = _allUnitsInArea select {
                private _unitActualType = WL_ASSET_TYPE(_x);
                private _isSmartMine = WL_ASSET(_unitActualType, "smartMineAP", 0) > 0 || WL_ASSET(_unitActualType, "smartMineAT", 0) > 0;
                private _isDumbMine = WL_ASSET(_unitActualType, "dumbMine", 0) > 0;
                _isSmartMine || _isDumbMine
            };
            _minesInArea append _mineEquipInArea;

            [player, "demine", _asset, _minesInArea] remoteExec ["WL2_fnc_handleClientRequest", 2];

            private _obstaclesInArea = _allUnitsInArea select {
                WL_UNIT(_x, "obstacle", 0) == 1;
            };
            {
                [_x, player] remoteExec ["WL2_fnc_demolishComplete", 2];
            } forEach _obstaclesInArea;

            uiSleep 1;
            ropeDestroy _cable;

            deleteVehicle _dummyStart;
            deleteVehicle _dummyEnd;
        };
	},
	[],
	7,
	false,
	true,
	"",
	"driver _target == _this && _target getVariable ['WL2_mineClearCharges', 0] > 0",
	-98,
	false
];