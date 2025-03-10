#include "..\..\warlords_constants.inc"

params ["_asset"];

[
    _asset,
    "<t color='#ff0000'>Begin Demolition</t>",
    "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_secure_ca.paa",
    "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_secure_ca.paa",
    "speed player < 1 && vehicle player == player",
    "speed player < 1 && vehicle player == player",
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
        _charge setPosASL (getPosASL _target);
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

        private _radius = boundingBoxReal _target # 2;
        while { alive _caller && alive _target } do {
            if (BIS_WL_spacePressed) then {
                break;
            };
            if (BIS_WL_backspacePressed) then {
                _cancelCharge = true;
                break;
            };
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

        private _targetChildren = _target getVariable ["WL2_children", []];
        _targetChildren pushBack _charge;
        _target setVariable ["WL2_children", _targetChildren, true];

        [
            _charge,
            "<t color='#00ff00'>Stop Demolition</t>",
            "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_secure_ca.paa",
            "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_secure_ca.paa",
            "speed player < 1",
            "speed player < 1",
            {},
            {
                private _disarmSounds = [
                    "a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_hard_01.wss",
                    "a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_hard_02.wss",
                    "a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_hard_03.wss",
                    "a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_hard_04.wss",
                    "a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_soft_01.wss",
                    "a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_soft_02.wss",
                    "a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_soft_03.wss",
                    "a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_metal_01.wss",
                    "a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_metal_02.wss",
                    "a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_metal_03.wss",
                    "a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_metal_04.wss",
                    "a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_plastic_01.wss",
                    "a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_plastic_02.wss",
                    "a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_plastic_03.wss",
                    "a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_plastic_04.wss"
                ];
                playSound3D [selectRandom _disarmSounds, _target, false, getPosASL _target, 2, 1, 200, 0];
            },
            {
                params ["_target", "_caller", "_actionId", "_arguments"];
                private _demolishable = _target getVariable ["WL_demolishable", objNull];
                private _charges = _target getVariable ["WL2_children", []];
                _charges = _charges - [_demolishable];
                _target setVariable ["WL2_children", _charges, true];
                deleteVehicle _target;
            },
            {},
            [],
            10,
            100,
            false,
            false
        ] call BIS_fnc_holdActionAdd;

        _charge setVariable ["WL_demolishTime", serverTime, true];
        _charge setVariable ["WL_demolisher", _caller, true];

        [_charge] remoteExec ["WL2_fnc_demolishChargeAction", 0];
    },
    {},
    [],
    5,
    100,
    false,
    false
] call BIS_fnc_holdActionAdd;