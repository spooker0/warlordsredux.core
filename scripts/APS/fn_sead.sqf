#include "includes.inc"
params ["_projectile", "_unit"];

private _munitionList = _unit getVariable ["DIS_munitionList", []];
_munitionList pushBack _projectile;
_munitionList = _munitionList select { alive _x };
_unit setVariable ["DIS_munitionList", _munitionList];
_projectile setVariable ["WL2_missileType", "ARM"];

private _projectileOverride = _projectile getVariable ["APS_ammoOverride", typeof _projectile];
if (!isNull (missileTarget _projectile)) exitWith {
    if (_projectileOverride != typeof _projectile) then {
        _projectile setVariable ["APS_ammoConsumptionOverride", 1];
    };
};

private _target = _unit getVariable ["WL2_selectedTargetSEAD", objNull];
if (!alive _target) then {
    private _seadTargets = [_unit] call DIS_fnc_getSeadTarget;
    if (count _seadTargets > 0) then {
        _target = _seadTargets # 0 # 0;
    };
};

private _isInAngle = [getPosATL _projectile, getDir _projectile, 120, getPosATL _target] call WL2_fnc_inAngleCheck;

if (!alive _target || !_isInAngle) exitWith {
    if (_projectileOverride != typeof _projectile) then {
        _projectile setVariable ["APS_ammoConsumptionOverride", 1];
    };
};

_projectile setVariable ["DIS_ultimateTarget", _target];

if (_target isKindOf "Air") exitWith {
    _projectile setMissileTarget [_target, true];
};

private _terminal = false;
private _lastTargetPos = getPosASL _target;
private _laser = objNull;

private _projectileSpeed = getNumber (configfile >> "CfgAmmo" >> typeof _projectile >> "maxSpeed");
_projectileSpeed = _projectileSpeed max 250;

private _pitch = (_unit call BIS_fnc_getPitchBank) # 0;
private _attackDistance = linearConversion [-15, 15, _pitch, 500, 1000, true];

while { alive _projectile } do {
    if (alive _target) then {
        private _targetPos = getPosASL _target;
        if (_projectile distance _laser > _attackDistance && !_terminal) then {
            if (!alive _laser) then {
                _laser = createVehicleLocal ["LaserTargetC", [0, 0, 0], [], 0, "NONE"];
            };

            _laser setPosASL (_targetPos vectorAdd [0, 0, 500]);
            _projectile setVelocityModelSpace [0, _projectileSpeed, 0];
            _projectile setMissileTarget [_laser, true];
        } else {
            private _targetVectorDirAndUp = [getPosASL _projectile, _targetPos] call BIS_fnc_findLookAt;
            private _currentVectorDir = vectorDir _projectile;
            private _currentVectorUp = vectorUp _projectile;

            private _actualVectorDir = vectorLinearConversion [0, 1, 0.1, _currentVectorDir, _targetVectorDirAndUp # 0, true];
            private _actualVectorUp = vectorLinearConversion [0, 1, 0.1, _currentVectorUp, _targetVectorDirAndUp # 1, true];
            _projectile setVectorDirAndUp [_actualVectorDir, _actualVectorUp];

            _projectile setVelocityModelSpace [0, 250, 0];

            _terminal = true;
            deleteVehicle _laser;

            _projectile setMissileTarget [_target, true];
        };
        _lastTargetPos = _targetPos;
    } else {
        _laser setPosASL _lastTargetPos;
        _projectile setMissileTarget [_laser, true];
    };

    sleep 0.001;
};

sleep 3;
deleteVehicle _laser;
deleteVehicle _projectile;