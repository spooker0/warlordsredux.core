#include "includes.inc"
params ["_asset", "_radius"];
if (isDedicated) exitWith {};

private _iteration = 0;
private _airChecks = _asset isKindOf "Air";
while { alive _asset } do {
    uiSleep 4;

    private _assetPos = _asset modelToWorld [0, 0, 0];

    if (_airChecks) then {
        if (cameraOn != _asset) then {
            continue;
        };

        private _altitude = _assetPos # 2;
        if (_altitude < 100) then {
            continue;
        };
    };

    private _assetSide = [_asset] call WL2_fnc_getAssetSide;

    private _enemyUnits = switch (_assetSide) do {
        case west: { BIS_WL_eastOwnedVehicles + BIS_WL_guerOwnedVehicles };
        case east: { BIS_WL_westOwnedVehicles + BIS_WL_guerOwnedVehicles };
        default { [] };
    };
    if (isNil "_enemyUnits") then {
        _enemyUnits = [];
    };

    private _vehiclesInRadius = _enemyUnits select {
        _x isKindOf "Air"
    } select {
        _x distance2D _assetPos < _radius;
    } select {
        private _vehiclePos = _x modelToWorldVisual [0, 0, 0];
        _vehiclePos # 2 > 50 &&
        [_assetPos, getDir _asset, 60, _vehiclePos] call WL2_fnc_inAngleCheck;
    };

    if (_airChecks) then {
        playSoundUI ["radarTargetLost", 2, 1, true];
    };

    if (count _vehiclesInRadius > 0) then {
        [_vehiclesInRadius] call WL2_fnc_reconReward;
        [_vehiclesInRadius, 10] remoteExec ["WL2_fnc_reportTargets", _assetSide];
    };
};