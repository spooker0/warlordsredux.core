#include "includes.inc"

params ["_asset"];
private _side = BIS_WL_playerSide;
while { alive _asset } do {
    uiSleep 1;

    private _target = laserTarget _asset;
    if (isNull _target) then {
        continue;
    };

    if (cameraOn == _asset) then {
        uiNamespace setVariable ["WL2_currentLaser", _asset];
    };

    private _laserDistance = _asset distance _target;
    if (_laserDistance > 3000) then {
        continue;
    };

    private _enemyUnits = switch (_side) do {
        case west: { BIS_WL_eastOwnedVehicles + BIS_WL_guerOwnedVehicles };
        case east: { BIS_WL_westOwnedVehicles + BIS_WL_guerOwnedVehicles };
        case independent: { BIS_WL_westOwnedVehicles + BIS_WL_eastOwnedVehicles };
        default { [] };
    };

    private _enemiesNear = _enemyUnits select {
        alive _x;
    } select {
        _x distance _target < 50;
    } select {
        _x isKindOf "Air";
    } select {
        private _isDrone = [_x] call WL2_fnc_isDrone;
        _isDrone || _laserDistance < 1500
    };

    {
        [_x, player] remoteExec ["WL2_fnc_uavJammed", 2];
    } forEach _enemiesNear;
};