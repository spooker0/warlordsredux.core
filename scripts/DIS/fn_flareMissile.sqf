#include "includes.inc"
params ["_projectile", "_unit", ["_samMaxDistance", WL_SAM_MAX_DISTANCE]];

if (!alive _projectile || !local _projectile) exitWith {};

private _projectileType = typeOf _projectile;
private _ammoType = _projectile getVariable ["APS_ammoOverride", _projectileType];
private _ammoConfig = APS_projectileConfig getOrDefault [_ammoType, createHashMap];
private _sam = _ammoConfig getOrDefault ["sam", 0];
if (_sam <= 0 && count _this == 2) exitWith {};

private _flareInitialized = _projectile getVariable ["DIS_flareInitialized", false];
if (_flareInitialized) exitWith {};

_projectile setVariable ["DIS_flareInitialized", true];

private _missileConfig = configFile >> "CfgAmmo" >> _projectileType;
private _isCombatAirPatrol = _ammoType == "ammo_Missile_CAP";
private _isAirLauncher = _unit isKindOf "Air";

private _launcherSide = [_unit] call WL2_fnc_getAssetSide;
if (_isCombatAirPatrol) then {
    private _sectorSide = _unit getVariable ["BIS_WL_owner", independent];
    _launcherSide = _unit getVariable ["WL2_forwardBaseOwner", _sectorSide];
};

private _originalTarget = _projectile getVariable ["DIS_ultimateTarget", objNull];
if (isNull _originalTarget) then {
    _originalTarget = missileTarget _projectile;
};

private _launcherAmmoConfig = _unit getVariable ["WL2_currentAmmoConfig", createHashMap];
private _loal = _launcherAmmoConfig getOrDefault ["loal", false];
if (_loal) then {
    private _selectedTarget = _unit getVariable ["WL2_selectedTargetAA", objNull];
    private _selectedLockPercent = _unit getVariable ["WL2_selectedLockPercentAA", 0];
    if (!isNull _selectedTarget && isNull _originalTarget && _selectedLockPercent >= 100) then {
        private _isFlying = (_selectedTarget modelToWorld [0, 0, 0]) # 2 > 30;
        if (!_isFlying) exitWith {};

        private _unitSpeed = speed _unit;
        _projectile setVelocityModelSpace [0, _unitSpeed * 3.6 + 100, 0];
        _projectile setMissileTarget [_selectedTarget, true];
        _originalTarget = _selectedTarget;
    };
};

private _detectors = (BIS_WL_westOwnedVehicles + BIS_WL_eastOwnedVehicles) select {
    alive _x;
} select {
    [_x] call WL2_fnc_getAssetSide != _launcherSide;
} select {
    private _detectionRadius = _x getVariable ["DIS_missileDetector", 0];
    _detectionRadius > 0 && _x distance2D _projectile < _detectionRadius;
};

if (count _detectors > 0) then {
    private _detectorSide = [_detectors # 0] call WL2_fnc_getAssetSide;
    [[_unit], 15] remoteExec ["WL2_fnc_reportTargets", _detectorSide];
};

private _launchPosition = getPosASL _unit;
private _launcherSpeed = speed _unit;
private _flareMin = _ammoConfig getOrDefault ["flareMin", 0];
private _flareMax = _ammoConfig getOrDefault ["flareMax", 0];
private _optimalRange = (_flareMin + _flareMax) / 2;
private _halfWidth = ((_flareMax - _flareMin) / 2) max 0;

if (!isNull _originalTarget) then {
    private _targetPosition = getPosASL _originalTarget;
    private _altitudeDifference = (_launchPosition # 2) - (_targetPosition # 2);
    private _minimumHalfWidth = 20 min _halfWidth;
    _halfWidth = linearConversion [0, 5000, _altitudeDifference, _halfWidth, _minimumHalfWidth, true];

    if (_isAirLauncher) then {
        private _angleToEnemy = [_launchPosition, getDir _unit, _targetPosition] call WL2_fnc_getAngle;
        private _angleFactor = linearConversion [0, 180, _angleToEnemy, 1, 0, true];
        _launcherSpeed = _launcherSpeed * _angleFactor;
    };
};

_flareMin = _optimalRange - _halfWidth;
_flareMax = _optimalRange + _halfWidth;

private _speedFactor = if (_isCombatAirPatrol) then {
    2
} else {
    ((_launcherSpeed / WL_SAM_FAST_THRESHOLD) max 0.6) min 1
};
_speedFactor = _speedFactor * 1.5;
private _missileSpeed = getNumber (_missileConfig >> "missileLockMaxSpeed") * _speedFactor;

_projectile setVariable ["DIS_flareMin", _flareMin, true];
_projectile setVariable ["DIS_flareMax", _flareMax, true];
_projectile setVariable ["DIS_ultimateTarget", _originalTarget];

private _munitionList = _unit getVariable ["DIS_munitionList", []];
_munitionList pushBackUnique _projectile;
_munitionList = _munitionList select {
    alive _x;
};
_unit setVariable ["DIS_munitionList", _munitionList];

private _ammoSensors = "true" configClasses (_missileConfig >> "Components" >> "SensorsManagerComponent" >> "Components");
_ammoSensors = _ammoSensors apply {
    configName _x;
};
private _missileType = if ("IRSensorComponent" in _ammoSensors) then {
    2;
} else {
    3;
};
_projectile setVariable ["WL2_missileType", format ["FOX-%1", _missileType]];

private _missileTypeData = call DIS_fnc_getMissileType;
private _projectileName = _missileTypeData getOrDefault [_ammoType, "MISSILE"];
_projectileName = _projectile getVariable ["WL2_missileNameOverride", _projectileName];
_projectile setVariable ["WL2_missileNameOverride", _projectileName];

if (_isAirLauncher) then {
    _samMaxDistance = 30000;
};

private _isLOAL = getNumber (_missileConfig >> "autoSeekTarget") == 1;
private _warningLauncher = if (_isCombatAirPatrol) then {
    objNull;
} else {
    _unit;
};

if (alive _originalTarget) then {
    [_originalTarget, _warningLauncher, _projectile] remoteExec ["WL2_fnc_warnIncomingMissile", _originalTarget];
};

private _playerSide = if (isServer) then {
    side group _unit;
} else {
    BIS_WL_playerSide;
};
if (_isCombatAirPatrol) then {
    _playerSide = _launcherSide;
};

uiSleep 0.5;

while { alive _projectile } do {
    private _missileDefeated = _projectile getVariable ["DIS_missileDefeated", false];
    if (_missileDefeated) then {
        _projectile setVelocityModelSpace [0, _missileSpeed / 5, 0];
        _projectile setMissileTarget [objNull, true];
        [player, "flared"] remoteExec ["WL2_fnc_handleClientRequest", 2];
        break;
    };

    private _currentMissileTarget = missileTarget _projectile;
    private _currentTargetSide = [_currentMissileTarget] call WL2_fnc_getAssetSide;
    if (_currentTargetSide == _playerSide) then {
        _projectile setVariable ["DIS_missileDefeated", true];
        triggerAmmo _projectile;
        ["Missile detonated to avoid seeking friendly target."] call WL2_fnc_smoothText;
        break;
    };

    private _missileStateOverride = _projectile getVariable ["WL2_missileStateOverride", ""];
    if (_missileStateOverride == "BOOST") then {
        uiSleep 0.01;
        continue;
    };

    private _projectilePosition = getPosASL _projectile;
    private _targetPosition = getPosASL _originalTarget;
    if (!isNull _originalTarget) then {
        private _inFrontAngle = [_projectilePosition, getDir _projectile, 180, _targetPosition] call WL2_fnc_inAngleCheck;
        if (!_inFrontAngle) then {
            triggerAmmo _projectile;
        };

        private _targetVectorDirAndUp = [_projectilePosition, _targetPosition] call BIS_fnc_findLookAt;
        _projectile setVectorDirAndUp _targetVectorDirAndUp;
        _projectile setMissileTarget [_originalTarget, true];
    };

    _currentMissileTarget = missileTarget _projectile;
    // Ghost missile relocking check.
    if (_isLOAL && alive _currentMissileTarget && _currentMissileTarget != _originalTarget) then {
        if (alive _originalTarget) then {
            ["Missile lost track on multiple targets."] call WL2_fnc_smoothText;
        };

        _projectile setVariable ["DIS_missileDefeated", true];
        triggerAmmo _projectile;
        break;
    };

    if (_unit distance _projectilePosition > _samMaxDistance) then {
        if (alive _originalTarget && !(_projectilePosition isEqualTo [0, 0, 0])) then {
            ["Missile lost track past maximum control distance from launcher."] call WL2_fnc_smoothText;
        };

        _projectile setVariable ["DIS_missileDefeated", true];
        triggerAmmo _projectile;
        break;
    };

    _projectile setAngularVelocityModelSpace [0, 0, 0];
    _projectile setVelocityModelSpace [0, _missileSpeed, 0];

    uiSleep 0.01;
};
