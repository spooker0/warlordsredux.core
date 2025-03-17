#include "..\..\warlords_constants.inc"

params ["_asset"];

[
    _asset,
    "<t color='#ff0000'>Begin Demolition</t>",
    "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_secure_ca.paa",
    "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_secure_ca.paa",
    "call WL2_fnc_demolishEligibility",
    "call WL2_fnc_demolishEligibility",
    {},
    {
        params ["_target", "_caller", "_actionId", "_arguments", "_frame", "_maxFrame"];
        if (_frame % 4 == 0) then {
            playSound3D ["\a3\sounds_f\arsenal\tools\minedetector_beep_01.wss", player, false, getPosASL player, 2, 1, 200];
        };
    },
    {
        params ["_target", "_caller", "_actionId", "_arguments"];
        private _dummy = createVehicle ["DemoCharge_F", getPosATL _target, [], 0, "FLY"];
        _dummy setPosASL (getPosASL _target);
        _dummy allowDamage false;

        private _charge = createVehicle ["DemoCharge_F", getPosATL _dummy, [], 0, "FLY"];
        _charge setPosASL (getPosASL _dummy);
        _charge allowDamage false;

        [player, "placeCharge"] call WL2_fnc_hintHandle;
        private _forward = [];
        private _surfaceNormal = [];
        private _cancelCharge = false;

        private _strongholdSector = _target getVariable ["WL_strongholdSector", objNull];
        private _objectScale = if (isNull _strongholdSector) then {
            3
        } else {
            5
        };

        private _radius = boundingBoxReal _target # 2;
        sleep 0.1;
        waitUntil {
            sleep 0.01;
            inputAction "BuldSelect" == 0 && inputAction "navigateMenu" == 0;
        };
        while { alive _caller && alive _target } do {
            if (inputAction "BuldSelect" > 0) then {
                break;
            };
            if (inputAction "navigateMenu" > 0) then {
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

            detach _charge;

            private _targetIntersections = lineIntersectsSurfaces [
                AGLToASL positionCameraToWorld [0, 0, 0],
                AGLToASL positionCameraToWorld [0, 0, 20],
                _caller,
                _charge,
                true,
                1,
                "VIEW",
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
            _charge setVectorDirAndUp [_forward, _surfaceNormal];

            [_charge, _dummy] call BIS_fnc_attachToRelative;
            _charge setObjectScale _objectScale;
            sleep 0.001;
        };

        deleteVehicle _dummy;

        [player, "placeCharge", false] call WL2_fnc_hintHandle;

        if (_cancelCharge || !alive _target || !alive _caller) exitWith {
            playSoundUI ["AddItemFailed"];
            deleteVehicle _charge;
        };

        [_charge, serverTime, _caller, _target] remoteExec ["WL2_fnc_demolishChargeAction", 0];
    },
    {},
    [],
    5,
    100,
    false,
    false
] call BIS_fnc_holdActionAdd;