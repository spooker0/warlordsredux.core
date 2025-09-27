#include "includes.inc"
params ["_destroyerBase", "_mrls", "_controller", "_firstSpawn"];

_mrls addEventHandler ["Fired", {
    _this spawn {
        params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_gunner"];

        if (player distance2D _unit < 1000) then {
            [_unit, _projectile] spawn {
                params ["_unit", "_projectile"];
                private _destroyerId = _unit getVariable ["WL2_destroyerId", 0];

                private _camera = "camera" camCreate (getPosASL _unit);
                _camera cameraEffect ["Terminate", "BACK", format ["destroyercam%1", _destroyerId]];
                _camera cameraEffect ["Internal", "BACK", format ["destroyercam%1", _destroyerId]];
                _camera camSetTarget _projectile;
                _camera camSetRelPos [0, -3, 0.4];
                _camera camCommit 0;
                _camera attachTo [_projectile];

                [_camera, _projectile, _unit] spawn {
                    params ["_camera", "_projectile", "_unit"];
                    while { alive _projectile } do {
                        sleep 1;
                    };

                    camDestroy _camera;
                };
            };
        };

        if (cameraOn != _unit) exitWith {};

        private _inRangeCalculation = [_unit] call DIS_fnc_calculateInRange;
        private _targetCoordinates = _inRangeCalculation # 3;
        _projectile setVariable ["DIS_targetCoordinates", _targetCoordinates];
        [_projectile, _unit] spawn DIS_fnc_gpsMunition;
        [_projectile, player] call DIS_fnc_startMissileCamera;

        private _currentAmmo = _unit magazineTurretAmmo ["magazine_Missiles_Cruise_01_x18", [0]];
        private _newControllerImage = format [
            "#(rgb,512,512,3)text(1,1,""PuristaBold"",0.3,""#000000"",""#ffffff"",""AMMO\n%1"")",
            _currentAmmo
        ];

        private _controller = _unit getVariable ["WL2_destroyerController", objNull];
        _controller setObjectTextureGlobal [3, _newControllerImage];
    };
}];

if (!_firstSpawn) exitWith {};

private _destroyerDir = getDir _destroyerBase;

private _staticProps = [
    ["Land_PortableDesk_01_olive_F", [-0.579102,-34.438,19.6331], 0],
    ["Land_PortableDesk_01_olive_F", [1.87598, -34.4341, 19.6326], 0],
    ["Land_PortableGenerator_01_sand_F", [-1.32324, -33.9192, 19.5646], 89.5469],
    ["Land_PortableServer_01_cover_olive_F", [-1.54688, -34.4224, 20.1178], -192.838],
    ["Land_DeskChair_01_sand_F", [-0.648438, -35.3083, 19.4113], -99.8427],
    ["Land_MultiScreenComputer_01_closed_sand_F", [1.00293, -34.3979, 20.3257], 56.4011],
    ["Land_laptop_03_closed_olive_F", [1.56152, -34.5183, 20.2523], -23.635],
    ["Land_IPPhone_01_olive_F", [1.94238, -34.489, 20.1216], -1.554],
    ["Land_BatteryPack_01_open_sand_F", [1.01367, -34.7173, 19.7958], 153.802],
    ["Land_BatteryPack_01_closed_sand_F", [1.21875, -34.3982, 19.6868], -1.62357],
    ["Land_PortableServer_01_sand_F", [1.15527, -34.5205, 19.3637], -3.05557],
    ["Land_DeskChair_01_black_F", [2.62598, -34.708, 19.4234], 152.338],
    ["Land_Router_01_sand_F", [2.79883, -34.4292, 20.1897], -177.399]
];

{
    private _className = _x select 0;
    private _propPosition = _x select 1;
    private _direction = _x select 2;

    private _staticProp = createSimpleObject [_className, _propPosition, true];
    _staticProp setDir (_direction + _destroyerDir);

    private _staticPropPos = _destroyerBase modelToWorldWorld _propPosition;
    _staticProp setPosWorld _staticPropPos;

    _staticProp allowDamage false;
    _staticProp enableSimulation false;
} forEach _staticProps;

_controller addAction [
    "<t color='#FF0000'>Control Missile Battery</t>",
    {
        _this spawn {
            params ["_target", "_caller", "_actionId"];
            private _mrls = _target getVariable ["WL2_destroyerVLS", objNull];
            if (isNull _mrls) exitWith {
                systemChat "Missile Battery not found.";
                playSoundUI ["AddItemFailed"];
            };
            _target setVariable ["WL2_controller", _caller, true];

            _mrls switchCamera "External";
            player remoteControl (crew _mrls select 0);

            uiNamespace setVariable ["WL2_usingVLS", true];
            private _areControlsReady = true;
            while { 
                cameraOn == _mrls &&
                alive player &&
                lifeState player != "INCAPACITATED"
            } do {
                sleep 0.1;
            };

            uiNamespace setVariable ["WL2_usingVLS", false];
            _target setVariable ["WL2_controller", objNull, true];
        };
    },
    [],
    100,
    false,
    false,
    "",
    "isNull (_target getVariable [""WL2_controller"", objNull])",
    30,
    false
];