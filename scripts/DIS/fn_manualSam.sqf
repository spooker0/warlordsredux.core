#include "includes.inc"
params ["_projectile", "_unit", "_samParams"];

_projectile setMissileTarget [objNull, true];

private _assetSide = [_unit] call WL2_fnc_getAssetSide;
private _enemyUnits = switch (_assetSide) do {
    case west: { BIS_WL_eastOwnedVehicles + BIS_WL_guerOwnedVehicles };
    case east: { BIS_WL_westOwnedVehicles + BIS_WL_guerOwnedVehicles };
    default { [] };
};

private _detectors = _enemyUnits select {
    private _detectionRadius = _x getVariable ["DIS_missileDetector", 0];
    _detectionRadius > 0 && (_x distance2D _projectile) < _detectionRadius
};

if (count _detectors > 0) then {
    private _detectorSide = [_detectors # 0] call WL2_fnc_getAssetSide;
    [[_unit], 15] remoteExec ["WL2_fnc_reportTargets", _detectorSide];
};

private _munitionList = _unit getVariable ["DIS_munitionList", []];
_munitionList pushBack _projectile;
_munitionList = _munitionList select { alive _x };
_unit setVariable ["DIS_munitionList", _munitionList];

_projectile setVariable ["WL2_missileType", "MISSILE"];

private _missileTypeData = call DIS_fnc_getMissileType;
private _projectileType = _projectile getVariable ["APS_ammoOverride", typeof _projectile];
private _projectileTypeName = _missileTypeData getOrDefault [_projectileType, "BEAM RIDER"];
_projectile setVariable ["WL2_missileNameOverride", _projectileTypeName, true];

_samParams params ["_speed", "_lead", "_maxRange"];

private _enemiesCanWarn = _enemyUnits select {
    _x isKindOf "Air";
} select {
    _x distance _unit < _maxRange
};
private _enemiesHaveWarned = [];

uiSleep 0.1;

while { alive _projectile } do {
    if (cameraOn != _unit) then {
        triggerAmmo _projectile;
        break;
    };

    private _distanceToLauncher = _projectile distance _unit;
    if (_distanceToLauncher > _maxRange) then {
        triggerAmmo _projectile;
        [format ["Missile out of range. Max range: %1M", _maxRange]] call WL2_fnc_smoothText;
        break;
    };

    private _enemiesInWarnRange = _enemiesCanWarn select {
        _x distance _projectile < 2000
    };
    {
        if (_x in _enemiesHaveWarned) then {
            continue;
        };

        [_x, _unit, _projectile] remoteExec ["WL2_fnc_warnIncomingMissile", _x];
        _enemiesHaveWarned pushBack _x;
    } forEach _enemiesInWarnRange;

    private _guideDirection = _unit weaponDirection (currentWeapon _unit);
    private _guideOrigin = AGLtoASL (positionCameraToWorld [0, 0, 0]);
    private _guideSpot = _guideOrigin vectorAdd (_guideDirection vectorMultiply (_distanceToLauncher + _lead));

    private _findVector = [getPosASL _projectile, _guideSpot] call BIS_fnc_findLookAt;
    _projectile setVectorDirAndUp _findVector;

    _projectile setVelocityModelSpace [0, _speed, 0];
    _projectile setMissileTarget [objNull, true];

    private _distanceToDisplay = _distanceToLauncher / 1000;
    if (_distanceToDisplay > 0) then {
        // do not propagate
        _projectile setVariable ["WL2_missileNameOverride", format ["%1 %2 KM", _projectileTypeName, _distanceToDisplay toFixed 1]];
    };

    uiSleep 0.1;
};
