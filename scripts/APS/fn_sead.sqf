#include "includes.inc"
params ["_projectile", "_unit"];

private _munitionList = _unit getVariable ["DIS_munitionList", []];
_munitionList pushBack _projectile;
_munitionList = _munitionList select { alive _x };
_unit setVariable ["DIS_munitionList", _munitionList];
_projectile setVariable ["WL2_missileType", "ARM"];

private _target = _unit getVariable ["WL2_selectedTargetSEAD", objNull];
if (!alive _target) then {
    private _seadTargets = [_unit] call DIS_fnc_getSeadTarget;
    if (count _seadTargets > 0) then {
        _target = _seadTargets # 0 # 0;
    };
};

private _lockPercent = _unit getVariable ["WL2_selectedLockPercentSEAD", 0];
if (!isNull (missileTarget _projectile) || !alive _target || _lockPercent < 100) exitWith {
    _projectile setVariable ["APS_ammoConsumptionOverride", 1];
};

private _projectileOverride = _projectile getVariable ["APS_ammoOverride", typeof _projectile];
if (!alive _target) exitWith {
    if (_projectileOverride != typeof _projectile) then {
        _projectile setVariable ["APS_ammoConsumptionOverride", 1];
    };
};

_projectile setVariable ["DIS_ultimateTarget", _target];

if (_target isKindOf "Air") exitWith {
    _projectile setMissileTarget [_target, true];
};

private _terminal = false;

private _projectileSpeed = getNumber (configfile >> "CfgAmmo" >> typeof _projectile >> "maxSpeed");
_projectileSpeed = _projectileSpeed max 250;

private _pitch = (_unit call BIS_fnc_getPitchBank) # 0;
private _attackDistance = linearConversion [-15, 15, _pitch, 1000, 100, true];

private _targetPos = _target modelToWorldWorld [0, 0, 500];

while { alive _projectile } do {
    if (alive _target) then {
        if (_projectile distance2D _targetPos > _attackDistance && !_terminal) then {
            private _targetVectorDirAndUp = [getPosASL _projectile, _targetPos] call BIS_fnc_findLookAt;
            _projectile setVectorDirAndUp _targetVectorDirAndUp;
            _projectile setVelocityModelSpace [0, _projectileSpeed, 0];
        } else {
            _targetPos = getPosASL _target;
            private _targetVectorDirAndUp = [getPosASL _projectile, _targetPos] call BIS_fnc_findLookAt;
            _projectile setVectorDirAndUp _targetVectorDirAndUp;

            _projectile setVelocityModelSpace [0, 250, 0];
            _terminal = true;
            _projectile setMissileTarget [_target, true];
        };
    } else {
        break;
    };

    uiSleep 0.001;
};

uiSleep 3;
deleteVehicle _projectile;