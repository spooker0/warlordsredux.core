#include "..\warlords_constants.inc"

params ["_unit", "_selection", "_damage", "_source", "_projectile", "_hitIndex", "_instigator", "_hitPoint", "_directHit"];

if (lifeState _unit == "INCAPACITATED") exitWith {
    0.99;
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

private _isImpactDamage = isNull _source && _projectile == "";
private _playerVehicle = vehicle _unit;
private _isInVehicle = _playerVehicle != _unit && alive _playerVehicle;
private _vehicleMaxAps = _playerVehicle call APS_fnc_getMaxAmmo;
if (_isImpactDamage && _isInVehicle && _vehicleMaxAps > 0) exitWith {
    0;
};

if (_damage < 1) exitWith {
    _damage;
};

// Downed
moveOut _unit;
switchCamera player;
enableSentences false;

[_unit] spawn {
    params ["_unit"];
    {
        _x disableAI "ALL";
    } forEach (units _unit);

    _unit setCaptive true;
    _unit setUnconscious true;

    [_unit, false] remoteExec ["setPhysicsCollisionFlag", 0];

    private _unconsciousTime = _unit getVariable ["WL_unconsciousTime", 0];
    if (_unconsciousTime > 0) exitWith {};

    private _startTime = serverTime;
    private _downTime = 0;
    while { alive _unit && lifeState _unit == "INCAPACITATED" && _downTime < 90 } do {
        _downTime = serverTime - _startTime;
        _unit setPosASL (getPosASL _unit);
        switchCamera player;

        hintSilent format ["Downed for %1", round _downTime];
        _unit setVariable ["WL_unconsciousTime", _downTime];
        sleep 1;
    };

    hintSilent "";
    _downTime = serverTime - _startTime;
    if (_downTime >= 90) then {
        setPlayerRespawnTime 5;
        forceRespawn _unit;
    };
};

[_unit, _source, _instigator] remoteExec ["WL2_fnc_handleEntityRemoval", 2];
0.99;