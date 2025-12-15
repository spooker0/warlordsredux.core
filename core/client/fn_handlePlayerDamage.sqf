#include "includes.inc"
params ["_unit", "_selection", "_damage", "_source", "_projectile", "_hitIndex", "_instigator", "_hitPoint", "_directHit", "_context"];

if (_projectile != "" && _context == 2) then {
    private _existingProjectiles = uiNamespace getVariable ["WL2_damagedProjectiles", createHashMap];
    _existingProjectiles set [diag_tickTime, _projectile];
    uiNamespace setVariable ["WL2_damagedProjectiles", _existingProjectiles];
    uiNamespace setVariable ["WL2_damageSource", _source];
    uiNamespace setVariable ["WL2_damagedWeapon", currentWeapon _source];
};

if (_hitPoint == "incapacitated") then {
    _damage = 0.8 min _damage;
};

if (_projectile isKindOf "MineCore" || _projectile isKindOf "TimeBombCore") then {
    private _instigator = [_source, _instigator] call WL2_fnc_handleInstigator;
    if (side group _instigator == side group _unit) then {
        _damage = _unit getHit _selection;
    };
};

if (lifeState _unit == "INCAPACITATED") exitWith {
    _damage min 0.99;
};

private _homeBase = [WL2_base1, WL2_base2] select {
    (_x getVariable ["BIS_WL_owner", independent]) == (side group _unit)
};
if (count _homeBase == 0) exitWith {    // should not happen, will kill without downing
    _damage;
};
_homeBase = _homeBase # 0;

private _enemyTargetVar = format ["BIS_WL_currentTarget_%1", BIS_WL_enemySide];
private _enemyTarget = missionNamespace getVariable [_enemyTargetVar, objNull];
private _homeArea = _homeBase getVariable "objectAreaComplete";
private _inHomeBase = !isNil "_homeArea" && { _unit inArea _homeArea };
if (_homeBase != _enemyTarget && _inHomeBase) exitWith {
    0;
};

private _isImpactDamage = (isNull _source && _projectile == "") || _projectile == "FuelExplosion";
private _playerVehicle = vehicle _unit;
private _isInVehicle = _playerVehicle != _unit && alive _playerVehicle;
private _vehicleMaxAps = _playerVehicle call APS_fnc_getMaxAmmo;
if (_isImpactDamage && _isInVehicle && _vehicleMaxAps > 0) exitWith {
    _unit getHit _selection;
};

if (_damage < 1) exitWith {
    _damage;
};

// Downed
moveOut _unit;
switchCamera player;
private _unconsciousTime = _unit getVariable ["WL_unconsciousTime", 0];
if (_unconsciousTime == 0) then {
    _unit setVariable ["WL_unconsciousTime", 0.1];
    [_unit] spawn WL2_fnc_handlePlayerDown;
};

[_unit, _source, _instigator] remoteExec ["WL2_fnc_handleEntityRemoval", 2];
0.99;