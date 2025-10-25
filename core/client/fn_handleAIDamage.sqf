#include "includes.inc"
params ["_unit", "_selection", "_damage", "_source", "_projectile", "_hitIndex", "_instigator", "_hitPoint", "_directHit"];

if (_hitPoint == "incapacitated") then {
    _damage = 0.8 min _damage;
};

if (lifeState _unit == "INCAPACITATED") exitWith {
    _damage min 0.99;
};

if (_damage < 1) exitWith {
    _damage;
};

_unit setCaptive true;
_unit setUnconscious true;
[_unit] spawn {
    params ["_unit"];
    private _downedTime = serverTime;
    private _unconsciousTime = _unit getVariable ["WL_unconsciousTime", 0];
    if (_unconsciousTime > 0) exitWith {};
    _unit setVariable ["WL2_expirationTime", serverTime + 90, true];

    while { alive _unit && lifeState _unit == "INCAPACITATED" } do {
        uiSleep 1;
        if (serverTime - _downedTime > 90) then {
            deleteVehicle _unit;
            break;
        };
    };
};
[_unit, _source, _instigator] remoteExec ["WL2_fnc_handleEntityRemoval", 2];
0.99;