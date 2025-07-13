#include "includes.inc"
if (isNil "destroyerController") exitWith {};

destroyerVLS setVariable ["WL2_ignoreRange", true];

destroyerVLS addEventHandler ["Fired", {
    _this spawn {
        params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_gunner"];

        if (player distance2D _unit < 1000) then {
            [_unit, _projectile] spawn {
                params ["_unit", "_projectile"];
                private _camera = "camera" camCreate (getPosASL _unit);
                _camera cameraEffect ["Terminate", "BACK", "destroyercam"];
                _camera cameraEffect ["Internal", "BACK", "destroyercam"];
                _camera camSetTarget _projectile;
                _camera camSetRelPos [0, -3, 0.4];
                _camera camCommit 0;
                _camera attachTo [_projectile];

                [_camera, _projectile, _unit] spawn {
                    params ["_camera", "_projectile", "_unit"];
                    while { alive _projectile } do {
                        sleep 1;
                    };

                    private _bombsRemaining = _unit getVariable ["DIS_gpsBombs", []];
                    _bombsRemaining = _bombsRemaining select { alive _x };
                    if (count _bombsRemaining == 0) then {
                        _camera cameraEffect ["Terminate", "BACK", "destroyercam"];
                    };

                    camDestroy _camera;
                };
            };
        };

        if (cameraOn != destroyerVLS) exitWith {};

        private _inRangeCalculation = [_unit] call DIS_fnc_calculateInRange;
        private _targetCoordinates = _inRangeCalculation # 3;
        _projectile setVariable ["DIS_targetCoordinates", _targetCoordinates];
        [_projectile, _unit] spawn DIS_fnc_gpsMunition;
        [_projectile, player] call DIS_fnc_startMissileCamera;

        private _currentAmmo = destroyerVLS magazineTurretAmmo ["magazine_Missiles_Cruise_01_x18", [0]];
        private _newControllerImage = format [
            "#(rgb,512,512,3)text(1,1,""LucidaConsoleB"",0.15,""#000000"",""#ffffff"",""AMMO: %1"")",
            _currentAmmo
        ];
        destroyerController setObjectTextureGlobal [3, _newControllerImage];
    };
}];

destroyerController addAction [
    "<t color='#FF0000'>Control Missile Battery</t>",
    {
        _this spawn {
            params ["_target", "_caller", "_actionId"];
            _target setVariable ["WL2_controller", _caller, true];

            destroyerVLS switchCamera "External";
            player remoteControl (crew destroyerVLS select 0);

            private _display = uiNamespace getVariable ["RscWLGPSTargetingMenu", displayNull];
            if (isNull _display) then {
                "gpstarget" cutRsc ["RscWLGPSTargetingMenu", "PLAIN", -1, true, true];
                _display = uiNamespace getVariable "RscWLGPSTargetingMenu";
            };
            private _texture = _display displayCtrl 5502;
            // _texture ctrlWebBrowserAction ["OpenDevConsole"];

            private _controlParams = ["GPS CONTROLS", [
                ["Previous", "gunElevUp"],
                ["Next", "gunElevDown"],
                ["Enter coordinates", "0-9"]
            ]];
            ["GPS", _controlParams, 10] call WL2_fnc_showHint;

            _texture ctrlAddEventHandler ["PageLoaded", {
                params ["_texture"];
                [_texture] spawn {
                    params ["_texture"];
                    while { !isNull _texture } do {
                        [_texture] call DIS_fnc_sendGPSData;
                        sleep 0.5;
                    };
                };
            }];

            waitUntil {
                sleep 0.1;
                !alive player ||
                lifeState player == "INCAPACITATED" ||
                cameraOn != destroyerVLS ||
                isNull _texture;
            };

            _target setVariable ["WL2_controller", objNull, true];
            "gpstarget" cutText ["", "PLAIN"];
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