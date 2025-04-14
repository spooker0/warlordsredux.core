#include "constants.inc"

params ["_projectile", "_unit"];

private _target = _unit getVariable ["WL2_selectedAircraft", objNull];

if (isNull _target) exitWith {
    systemChat "No target found! Launch using the Extended SAM interface.";
    deleteVehicle _projectile;
};

private _altitude = getPosASL _projectile # 2;
private _targetAltitude = getPosASL _target # 2;

while { _altitude < _targetAltitude * 1.5 } do {
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
while { alive _projectile && alive _target && serverTime < _startTime + 3 } do {
    private _elapsedTime = serverTime - _startTime;
    private _currentMarker = _elapsedTime / 3;
    private _actualVectorDir = vectorLinearConversion [0, 1, _currentMarker, _currentVectorDir, _targetVectorDirAndUp # 0, true];
    private _actualVectorUp = vectorLinearConversion [0, 1, _currentMarker, _currentVectorUp, _targetVectorDirAndUp # 1, true];
    _projectile setVectorDirAndUp [_actualVectorDir, _actualVectorUp];
    _projectile setVelocityModelSpace [0, 1500, 0];

    sleep 0.01;
};

private _projectilePos = getPosASL _projectile;
_projectilePos set [2, _projectilePos # 2 + 10];
private _newProjectile = createVehicle ["ammo_Missile_mim145", _projectilePos, [], 0, "NONE"];
_newProjectile setVariable ["WL2_missileNameOverride", "DEATH", true];
[_newProjectile] remoteExec ["WL2_fnc_hideObjectOnAll", 2];
[_newProjectile, [player, player]] remoteExec ["setShotParents", 2];

_projectile attachTo [_newProjectile, [0, 0, 2]];
_newProjectile setMissileTarget [_target, true];

while { alive _newProjectile && alive _target } do {
    _newProjectile setMissileTarget [_target, true];

    _newProjectile setVelocityModelSpace [0, 1500, 0];

    private _vectorUp = vectorUp _newProjectile;
    _vectorUp set [0, 0];
    _vectorUp set [1, 0];
    _newProjectile setVectorDirAndUp [vectorDir _newProjectile, _vectorUp];

    private _angularVector = angularVelocityModelSpace _newProjectile;
    private _newAngularVector = _angularVector vectorMultiply 10;
    _newProjectile setAngularVelocityModelSpace _newAngularVector;

    if (_target distance _newProjectile < 300) then {
        private _detonationPoint = vectorLinearConversion [0, 1, 0.95, getPosASL _newProjectile, getPosASL _target];
        _projectile setPosASL _detonationPoint;

        triggerAmmo _projectile;
        triggerAmmo _newProjectile;

        break;
    };

    sleep 0.01;
};

sleep 3;

deleteVehicle _newProjectile;
deleteVehicle _projectile;