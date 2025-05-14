BIS_WL_playerSide call WL2_fnc_parsePurchaseList;

0 spawn {
    private _pingSound = "a3\ui_f_curator\data\sound\cfgsound\ping01.wss";

    private _notes = [
        [0.6674, 0.5],
        [0.6674, 0.5],
        [0.6674, 0.5],
        [0.8909, 1.0],
        [1.3348, 2.0],
        [1.1892, 0.5],
        [1.1225, 0.5],
        [1.0000, 0.5],
        [1.7818, 1.5],
        [1.3348, 2.0],
        [1.1892, 0.5],
        [1.1225, 0.5],
        [1.1892, 0.5],
        [1.0000, 0]
    ];

    {
        private _note = _x # 0;
        private _duration = _x # 1;

        playSoundUI [_pingSound, 2, _note];
        sleep _duration;
    } forEach _notes;
};

if (side group player != west) exitWith {};

player addAction [
    "<t color='#00FF00'>Jetpack (L)</t>",
    {
        params ["_unit", "_caller", "_actionId"];
        player setVariable ["WL2_jetpackTime", serverTime + 15];

        private _existingSpeed = velocityModelSpace _unit;
        _existingSpeed set [2, 25];
        _unit setVelocityModelSpace _existingSpeed;

        playSound3D ["a3\sounds_f_jets\vehicles\air\shared\fx_plane_jet_ejection_ext.wss", _unit, false, getPosASL _unit, 1, 1, 100, 0, false];

        private _lightPoint = createVehicle ["#lightpoint", getPosATL player, [], 0, "FLY"];
        _lightPoint setLightAttenuation [0, 0, 100, 0];
        _lightPoint setLightDayLight true;
        _lightPoint setLightFlareMaxDistance 500;
        _lightPoint setLightColor [1, 0.5, 0];
        _lightPoint setLightAmbient [1, 0.5, 0];
        _lightPoint setLightIntensity 200000;
        _lightPoint setLightUseFlare true;
        _lightPoint setLightFlareSize 1;
        _lightPoint setLightFlareMaxDistance 3000;
        _lightPoint attachTo [player, [0, 0.3, 0]];

        waitUntil { !isTouchingGround _unit };

        while { !isTouchingGround _unit } do {
            sleep 0.01;
            _existingSpeed = velocityModelSpace _unit;

            if (_existingSpeed # 2 > 0) then {
                continue;
            };

            private _playerPos = getPosASL player;
            private _intersections = lineIntersectsSurfaces [
                _playerPos,
                _playerPos vectorAdd [0, 0, -5],
                player,
                objNull,
                true,
                1,
                "FIRE",
                "VIEW",
                true
            ];

            if (count _intersections == 0) then {
                continue;
            };

            private _intersection = _intersections # 0;
            private _hit = _intersection # 0;
            if (_hit distance _playerPos < 2) then {
                break;
            };
        };

        _existingSpeed set [2, -2];
        _unit setVelocityModelSpace _existingSpeed;
        deleteVehicle _lightPoint;
    },
    nil,
	99,
	false,
	false,
	"BuldTerrainLower1m",
	"vehicle player == player && player getVariable ['WL2_jetpackTime', 0] < serverTime",
	30,
	false
];