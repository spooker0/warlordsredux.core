#include "includes.inc"
if (!hasInterface) exitWith {};

player addAction [
    localize "STR_WL_toggleVehicleLock",
    {
        [cameraOn] call WL2_fnc_vehicleLockAction;
    },
    [],
    -97,
    false,
    false,
    "Salute",
    "[cameraOn, _this] call WL2_fnc_lockActionEligibility",
    0,
    false
];