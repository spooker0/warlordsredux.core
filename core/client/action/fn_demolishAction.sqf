#include "..\..\warlords_constants.inc"

[
    player,
    "<t color='#ff0000'>Begin Demolition</t>",
    "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_secure_ca.paa",
    "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_secure_ca.paa",
    "call WL2_fnc_demolishEligibility",
    "call WL2_fnc_demolishEligibility",
    {},
    {
        params ["_target", "_caller", "_actionId", "_arguments", "_frame", "_maxFrame"];
        if (_frame % 4 == 0) then {
            playSound3D ["\a3\sounds_f\arsenal\tools\minedetector_beep_01.wss", player, false, getPosASL player, 1, 1, 200];
        };
    },
    {
        params ["_target", "_caller", "_actionId", "_arguments"];
        private _target = cursorObject;
        private _dummy = createVehicle ["VR_GroundIcon_01_F", [0, 0, 0], [], 0, "FLY"];
        _dummy setPosASL (getPosASL _target);
        _dummy allowDamage false;
        [_dummy] remoteExec ["WL2_fnc_hideObjectOnAll", 2];

        private _charge = createVehicleLocal ["DemoCharge_F", getPosATL player, [], 0, "FLY"];
        _charge setPosASL (getPosASL player);
        _charge allowDamage false;

        [player, "placeCharge"] call WL2_fnc_hintHandle;
        private _forward = [];
        private _surfaceNormal = [];
        private _cancelCharge = false;

        private _strongholdSector = _target getVariable ["WL_strongholdSector", objNull];
        private _isStrongholdDemolish = !isNull _strongholdSector;
        private _objectScale = if (_isStrongholdDemolish) then {
            6
        } else {
            3
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

            detach _charge;

            private _camOrigin = AGLToASL positionCameraToWorld [0, 0, 0];

            private _targetIntersections = lineIntersectsSurfaces [
                _camOrigin,
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
                private _firstIntersect = _targetIntersections # 0;
                [_firstIntersect # 0, _firstIntersect # 1];
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

        [player, "placeCharge", false] call WL2_fnc_hintHandle;

        if (_cancelCharge || !alive _target || !alive _caller) exitWith {
            playSoundUI ["AddItemFailed"];
            deleteVehicle _charge;
        };

        private _finalPosition = getPosASL _charge;
        private _finalDirAndUp = [vectorDir _charge, vectorUp _charge];

        deleteVehicle _charge;

        [_finalPosition, _finalDirAndUp, _caller, _target, _dummy, _isStrongholdDemolish] remoteExec ["WL2_fnc_demolishChargeAction", 0];
    },
    {},
    [],
    5,
    80,
    false,
    false
] call BIS_fnc_holdActionAdd;