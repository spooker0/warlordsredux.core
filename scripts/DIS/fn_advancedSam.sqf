#include "includes.inc"
params ["_projectile", "_unit"];

_projectile setVariable ["WL2_missileNameOverride", "HERCULES", true];
_projectile setVariable ["WL2_missileStateOverride", "BOOST", true];
_projectile setVariable ["APS_missileState", "BOOST", true];

private _target = _unit getVariable ["WL2_selectedAircraft", objNull];
if (isNull _target) exitWith {
    [_projectile, _unit] spawn DIS_fnc_frag;
    [_projectile, _unit, 14000, 14000, 8000] spawn DIS_fnc_maneuver;
};

sleep 0.5;
_projectile setMissileTarget [_target, true];

[_target, _unit, _projectile] remoteExec ["WL2_fnc_warnIncomingMissile", _target];

private _altitude = getPosASL _projectile # 2;
private _targetAltitude = getPosASL _target # 2;

while { _altitude < _targetAltitude * 2.0 } do {
    _projectile setVectorDirAndUp [[0, 0, 1], [0, 1, 0]];

    private _boostSpeed = linearConversion [0, 2000, _altitude, 40, 1500, true];
    _projectile setVelocityModelSpace [0, _boostSpeed, 0];

    _altitude = getPosASL _projectile # 2;
    _targetAltitude = getPosASL _target # 2;

    sleep 0.1;
};

private _currentPosition = getPosASL _projectile;
private _finalPosition = getPosASL _target;
private _targetVectorDirAndUp = [_currentPosition, _finalPosition] call BIS_fnc_findLookAt;

private _currentVectorDir = vectorDir _projectile;
private _currentVectorUp = vectorUp _projectile;

private _startTime = serverTime;
while { alive _projectile && alive _target && serverTime < _startTime + 1 } do {
    private _elapsedTime = serverTime - _startTime;
    private _actualVectorDir = vectorLinearConversion [0, 1, _elapsedTime, _currentVectorDir, _targetVectorDirAndUp # 0, true];
    private _actualVectorUp = vectorLinearConversion [0, 1, _elapsedTime, _currentVectorUp, _targetVectorDirAndUp # 1, true];
    _projectile setVectorDirAndUp [_actualVectorDir, _actualVectorUp];
    sleep 0.01;
};

_projectile setVelocityModelSpace [0, 1200, 0];

_projectile setVariable ["WL2_missileStateOverride", "", true];
_projectile setMissileTarget [_target, true];

[_projectile, _unit] spawn DIS_fnc_frag;
[_projectile, _unit, 14000, 14000, 8000] spawn DIS_fnc_maneuver;