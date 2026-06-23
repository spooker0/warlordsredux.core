#include "includes.inc"
params ["_projectile", "_unit", "_samParams"];

private _detectors = (BIS_WL_westOwnedVehicles + BIS_WL_eastOwnedVehicles) select { alive _x }
    select { [_x] call WL2_fnc_getAssetSide != [_unit] call WL2_fnc_getAssetSide }
    select {
        private _detectionRadius = _x getVariable ["DIS_missileDetector", 0];
        _detectionRadius > 0 && (_x distance2D _projectile) < _detectionRadius
    };

if (count _detectors > 0) then {
    private _detectorSide = [_detectors # 0] call WL2_fnc_getAssetSide;
    [[_unit], 5] remoteExec ["WL2_fnc_reportTargets", _detectorSide];
};

private _munitionList = _unit getVariable ["DIS_munitionList", []];
_munitionList pushBack _projectile;
_munitionList = _munitionList select { alive _x };
_unit setVariable ["DIS_munitionList", _munitionList];

_projectile setVariable ["WL2_missileType", "MISSILE"];

_samParams params ["_speed", "_lead"];

uiSleep 0.1;

while { alive _projectile } do {
    if (cameraOn != _unit) then {
        break;
    };

    private _distanceToLauncher = _projectile distance _unit;
    private _guideDirection = _unit weaponDirection (currentWeapon _unit);
    private _guideOrigin = AGLtoASL (positionCameraToWorld [0, 0, 0]);
    private _guideSpot = _guideOrigin vectorAdd (_guideDirection vectorMultiply (_distanceToLauncher + _lead));

    private _findVector = [getPosASL _projectile, _guideSpot] call BIS_fnc_findLookAt;
    _projectile setVectorDirAndUp _findVector;

    _projectile setVelocityModelSpace [0, _speed, 0];
    _projectile setMissileTarget [objNull, true];

    uiSleep 0.1;
};
