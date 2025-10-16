#include "includes.inc"
params ["_unit", "_selection", "_damage", "_source", "_projectile", "_hitIndex", "_instigator", "_hitPoint", "_directHit"];

if (_hitPoint == "incapacitated") then {
    _damage = 0.8 min _damage;
};

if (lifeState _unit == "INCAPACITATED") exitWith {
    0.99;
};

if (_damage < 1) exitWith {
    _damage;
};

_unit setCaptive true;
_unit setUnconscious true;
[_unit, _source, _instigator] remoteExec ["WL2_fnc_handleEntityRemoval", 2];
[_unit, false] remoteExec ["setPhysicsCollisionFlag", 0];
0.99;