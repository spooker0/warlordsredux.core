#include "includes.inc"
params ["_projectile", "_unit"];

private _munitionList = _unit getVariable ["DIS_munitionList", []];
_munitionList pushBack _projectile;
_munitionList = _munitionList select { alive _x };
_unit setVariable ["DIS_munitionList", _munitionList];
_projectile setVariable ["WL2_missileType", "ARM"];

private _target = _unit getVariable ["WL2_selectedTargetLaser", objNull];
if (!alive _target) exitWith {};

private _isInAngle = [getPosATL _projectile, getDir _projectile, 120, getPosATL _target] call WL2_fnc_inAngleCheck;
if (!_isInAngle) exitWith {};

private _lockPercent = _unit getVariable ["WL2_selectedLockPercentLaser", 0];
if (_lockPercent < 100) exitWith {};

_projectile setVariable ["DIS_ultimateTarget", _target];

if (_target isKindOf "Air") exitWith {
    _projectile setMissileTarget [_target, true];
};

private _terminal = false;
private _lastTargetPos = getPosASL _target;
private _laser = objNull;

private _projectileSpeed = getNumber (configfile >> "CfgAmmo" >> typeof _projectile >> "maxSpeed");
_projectileSpeed = _projectileSpeed max 500;

while { alive _projectile } do {
    if (alive _target) then {
        private _targetPos = getPosASL _target;
        if (_projectile distance _laser > 1000 && !_terminal) then {
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

            _projectile setVelocityModelSpace [0, 500, 0];

            _terminal = true;
            deleteVehicle _laser;

            _projectile setMissileTarget [_target, true];
        };
        _lastTargetPos = _targetPos;
    } else {
        _laser setPosASL _lastTargetPos;
        _projectile setMissileTarget [_laser, true];
    };

    uiSleep 0.001;
};

uiSleep 3;
deleteVehicle _laser;
deleteVehicle _projectile;