#include "..\..\warlords_constants.inc"

params ["_asset"];

[
    _asset,
    "<t color='#ff0000'>Begin Demolition</t>",
    "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_secure_ca.paa",
    "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_secure_ca.paa",
    "speed player < 1 && _target getVariable ['WL_demolishTime', -1] < 0 && vehicle player == player",
    "speed player < 1 && _target getVariable ['WL_demolishTime', -1] < 0 && vehicle player == player",
    {},
    {
        params ["_target", "_caller", "_actionId", "_arguments", "_frame", "_maxFrame"];
        if (_frame % 4 == 0) then {
            playSound3D ["\a3\sounds_f\arsenal\tools\minedetector_beep_01.wss", _target, false, getPosASL _target, 2, 1, 200];
        };
    },
    {
        params ["_target", "_caller", "_actionId", "_arguments"];
        private _charge = createVehicle ["DemoCharge_F", getPosATL _target, [], 0, "FLY"];
        _charge allowDamage false;

        [player, "placeCharge"] call WL2_fnc_hintHandle;
        private _forward = [];
        private _surfaceNormal = [];
        private _cancelCharge = false;

        BIS_WL_spacePressed = false;
        BIS_WL_backspacePressed = false;
        private _deployKeyHandle = (findDisplay 46) displayAddEventHandler ["KeyDown", {
            if (_this # 1 == 57) then {
                if !(BIS_WL_backspacePressed) then {
                    BIS_WL_spacePressed = true;
                };
            };
            if (_this # 1 == 14) then {
                if !(BIS_WL_spacePressed) then {
                    BIS_WL_backspacePressed = true;
                };
            };
        }];
        uiNamespace setVariable ["BIS_WL_deployKeyHandle", _deployKeyHandle];

        while { alive _caller && alive _target } do {
            if (BIS_WL_spacePressed) then {
                break;
            };
            if (BIS_WL_backspacePressed) then {
                _cancelCharge = true;
                break;
            };
            private _radius = boundingBoxReal _target # 2;
            if (_charge distance2D _target > (_radius + 2)) then {
                systemChat format ["Distance too far: %1m", round (_charge distance2D _target)];
                _cancelCharge = true;
                break;
            };
            if (_target getVariable ["WL_demolishTime", -1] >= 0) then {
                _cancelCharge = true;
                break;
            };

            private _targetIntersections = lineIntersectsSurfaces [
                AGLToASL positionCameraToWorld [0, 0, 0],
                AGLToASL positionCameraToWorld [0, 0, 20],
                _caller,
                _charge,
                true,
                1,
                "FIRE",
                "",
                true
            ];

            private _targetData = if (count _targetIntersections > 0) then {
                [_targetIntersections # 0 # 0, _targetIntersections # 0 # 1];
            } else {
                [getPosASL _caller, [0, 0, 1]];
            };

            _charge setPosASL (_targetData # 0);

            _surfaceNormal = vectorNormalized (_targetData # 1);
            private _dummyVector = [0, 1, 0];
            if (abs (_surfaceNormal vectorDotProduct _dummyVector) > 0.99) then {
                _dummyVector = [1, 0, 0];
            };
            _forward = vectorNormalized (_surfaceNormal vectorCrossProduct _dummyVector);
            private _up = vectorNormalized (_forward vectorCrossProduct _surfaceNormal);
            _charge setVectorDirAndUp [_forward, _surfaceNormal];

            sleep 0.001;
        };

        if (_cancelCharge) exitWith {
            playSoundUI ["AddItemFailed"];
            deleteVehicle _charge;
            [player, "placeCharge", false] call WL2_fnc_hintHandle;
        };

        private _deployKeyHandle = uiNamespace getVariable ["BIS_WL_deployKeyHandle", nil];
        if !(isNil "_deployKeyHandle") then {
            (findDisplay 46) displayRemoveEventHandler ["KeyDown", _deployKeyHandle];
        };
        uiNamespace setVariable ['BIS_WL_deployKeyHandle', nil];

        [player, "placeCharge", false] call WL2_fnc_hintHandle;

        [_charge, _target] call BIS_fnc_attachToRelative;
        _charge setObjectScale 3;
        _charge setVariable ["WL_demolishable", _target, true];

        private _targetChildren = [_charge];
        _target setVariable ["WL2_children", _targetChildren, true];

        [
            _charge,
            "<t color='#00ff00'>Stop Demolition</t>",
            "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_secure_ca.paa",
            "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_secure_ca.paa",
            "speed player < 1",
            "speed player < 1",
            {},
            {},
            {
                params ["_target", "_caller", "_actionId", "_arguments"];
                private _demolishable = _target getVariable ["WL_demolishable", objNull];
                _demolishable setVariable ["WL_demolishTime", -1, true];
                _demolishable setVariable ["WL_demolisher", objNull, true];
                deleteVehicle _target;
            },
            {},
            [],
            10,
            100,
            false,
            false
        ] call BIS_fnc_holdActionAdd;

        _target setVariable ["WL_demolishTime", serverTime, true];
        _target setVariable ["WL_demolisher", _caller, true];
    },
    {},
    [],
    5,
    100,
    false,
    false
] call BIS_fnc_holdActionAdd;

private _lightToggle = false;
private _lightPos = getPosASL _asset;
_lightPos set [2, _lightPos # 2 + 3];
private _lightPoint = "#lightpoint" createVehicle _lightPos;
_lightPoint setLightAttenuation [0.5, 0, 100, 0];
_lightPoint setLightDayLight true;
_lightPoint setLightFlareMaxDistance 500;
_lightPoint setLightColor[1, 0, 0];
_lightPoint setLightAmbient[1, 0, 0];
_lightPoint setLightIntensity 0;

while { alive _asset } do {
    private _sleepTime = 0.5;
    private _demolishTime = _asset getVariable ["WL_demolishTime", -1];
    private _demolishing = _demolishTime > 0;

    if (_demolishing) then {
        if (_lightToggle) then {
            _lightPoint setLightIntensity 100000;
        } else {
            _lightPoint setLightIntensity 0;
        };
        _lightToggle = !_lightToggle;

        private _childCharges = _asset getVariable ["WL2_children", []];
        if (count _childCharges > 0) then {
            private _childCharge = _childCharges # 0;
            // play sound locally
            playSound3D ["\a3\sounds_f\arsenal\tools\minedetector_beep_01.wss", _childCharge, false, getPosASL _childCharge, 2, 1, 200, 0, true];
            _lightPoint setPosASL getPosASL _childCharge;
        };

        private _timeRemaining = (_demolishTime + WL_DEMOLISH_TIME) - serverTime;
        if (_timeRemaining <= 0) then {
            private _demolisher = _asset getVariable ["WL_demolisher", objNull];
            if (local _demolisher) then {
                [_asset, _demolisher] remoteExec ["WL2_fnc_killRewardHandle", 2];
                private _explosion = createVehicle ["IEDUrbanBig_Remote_Ammo", getPos _asset, [], 0, "FLY"];
                triggerAmmo _explosion;
                sleep 1;
                // don't call FF script, this prevents runway griefing
                _asset setDamage [1, true, _demolisher];
            };
            deleteVehicle _lightPoint;
            sleep 3;
            deleteVehicle _asset;
            playSound3D ["a3\sounds_f\sfx\special_sfx\building_destroy_01.wss", objNull, false, _lightPos, 2, 1, 200, 0, true];
        } else {
            _sleepTime = (_timeRemaining / WL_DEMOLISH_TIME) max 0.1;
        };
    } else {
        _lightPoint setLightIntensity 0;
    };

    sleep _sleepTime;
};

deleteVehicle _lightPoint;