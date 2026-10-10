#include "includes.inc"
params ["_projectile", "_unit"];

private _target = _unit getVariable ["WL2_selectedTargetAA", objNull];
_target setVariable ["WL_incomingExtendedSam", _unit, true];

if (isNull _target) exitWith {
    ["No target found! Launch using the Extended SAM interface."] call WL2_fnc_smoothText;
    deleteVehicle _projectile;
};

_projectile setVariable ["DIS_ultimateTarget", _target];
_projectile setVariable ["WL2_missileStateOverride", "BOOST"];

private _missileName = if ([_unit] call WL2_fnc_getAssetSide == west) then {
    "RIM174";
} else {
    "HHQ9";
};
_projectile setVariable ["WL2_missileNameOverride", _missileName];

private _samMaxDistance = _unit getVariable ["DIS_advancedSamRange", 48000];
[_projectile, _unit, _samMaxDistance] spawn DIS_fnc_flareMissile;

private _altitude = getPosASL _projectile # 2;
private _targetAltitude = getPosASL _target # 2;
private _missileDefeated = false;

while { alive _projectile && alive _target && _altitude < _targetAltitude * 1.5 } do {
    _missileDefeated = _projectile getVariable ["DIS_missileDefeated", false];
    if (_missileDefeated) then {
        break;
    };

    _projectile setVectorDirAndUp [[0, 0, 1], [0, 1, 0]];

    private _boostSpeed = linearConversion [0, 2000, _altitude, 40, 1500, true];
    _projectile setVelocityModelSpace [0, _boostSpeed, 0];

    _altitude = getPosASL _projectile # 2;
    _targetAltitude = getPosASL _target # 2;

    uiSleep 0.1;
};

if (!alive _projectile || _missileDefeated) exitWith {};

private _currentPosition = getPosASL _projectile;
private _finalPosition = getPosASL _target;
private _targetVectorDirAndUp = [_currentPosition, _finalPosition] call BIS_fnc_findLookAt;

private _currentVectorDir = vectorDir _projectile;
private _currentVectorUp = vectorUp _projectile;

private _startTime = serverTime;
while { alive _projectile && alive _target && serverTime < _startTime + 3 } do {
    _missileDefeated = _projectile getVariable ["DIS_missileDefeated", false];
    if (_missileDefeated) then {
        break;
    };

    private _elapsedTime = serverTime - _startTime;
    private _currentMarker = _elapsedTime / 3;
    private _actualVectorDir = vectorLinearConversion [0, 1, _currentMarker, _currentVectorDir, _targetVectorDirAndUp # 0, true];
    private _actualVectorUp = vectorLinearConversion [0, 1, _currentMarker, _currentVectorUp, _targetVectorDirAndUp # 1, true];
    _projectile setVectorDirAndUp [_actualVectorDir, _actualVectorUp];
    _projectile setVelocityModelSpace [0, 1500, 0];

    uiSleep 0.01;
};

if (!alive _projectile || _missileDefeated) exitWith {};

private _projectilePos = getPosASL _projectile;
_projectilePos set [2, _projectilePos # 2 + 10];
private _newProjectile = createVehicle ["ammo_Missile_mim145", _projectilePos, [], 0, "NONE"];

private _ammoType = _projectile getVariable ["APS_ammoOverride", typeOf _projectile];
_newProjectile setVariable ["APS_ammoOverride", _ammoType];
_newProjectile setVariable ["DIS_ultimateTarget", _target];

_newProjectile setVariable ["WL2_missileNameOverride", _missileName, true];
[_newProjectile] remoteExec ["WL2_fnc_hideObjectOnAll", 2];
[_newProjectile, [player, player]] remoteExec ["setShotParents", 2];

_projectile attachTo [_newProjectile, [0, 0, 2]];
_newProjectile setMissileTarget [_target, true];
_newProjectile setVectorDirAndUp _targetVectorDirAndUp;

[_newProjectile, _unit, _samMaxDistance] spawn DIS_fnc_flareMissile;

private _munitionList = _unit getVariable ["DIS_munitionList", []];
_munitionList = _munitionList select {
    alive _x && _x != _projectile;
};
_munitionList pushBackUnique _newProjectile;
_unit setVariable ["DIS_munitionList", _munitionList];

while { alive _projectile && alive _newProjectile && alive _target } do {
    _missileDefeated = _projectile getVariable ["DIS_missileDefeated", false];
    private _newMissileDefeated = _newProjectile getVariable ["DIS_missileDefeated", false];
    if (_missileDefeated || _newMissileDefeated) then {
        _projectile setVariable ["DIS_missileDefeated", true];
        _newProjectile setVariable ["DIS_missileDefeated", true];

        triggerAmmo _projectile;
        triggerAmmo _newProjectile;

        break;
    };

    if (_target distance _newProjectile < 300) then {
        private _detonationPoint = vectorLinearConversion [0, 1, 0.95, getPosASL _newProjectile, getPosASL _target];
        _projectile setPosASL _detonationPoint;

        triggerAmmo _projectile;
        triggerAmmo _newProjectile;

        break;
    };

    uiSleep 0.01;
};

if (!alive _projectile || !alive _newProjectile) exitWith {
    deleteVehicle _newProjectile;
    deleteVehicle _projectile;
};

uiSleep 3;

deleteVehicle _newProjectile;
deleteVehicle _projectile;