#include "includes.inc"
params ["_unit", "_selection", "_damage", "_source", "_projectile", "_hitIndex", "_instigator", "_hitPoint", "_directHit"];

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

if (_damage < 1) exitWith {
    _damage;
};

moveOut _unit;
_unit setCaptive true;
_unit setUnconscious true;

[_unit] spawn {
    params ["_unit"];
    private _originalDeathPos = getPosWorld _unit;

    private _downedTime = serverTime;
    private _unconsciousTime = _unit getVariable ["WL_unconsciousTime", 0];
    if (_unconsciousTime > 0) exitWith {};
    _unit setVariable ["WL2_expirationTime", serverTime + 90, true];

    private _deadAnimations = [
        "Acts_StaticDeath_01",
        "Acts_StaticDeath_02",
        "Acts_StaticDeath_03",
        "Acts_StaticDeath_05",
        "Acts_StaticDeath_06",
        "Acts_StaticDeath_08",
        "Acts_StaticDeath_09"
    ];
    private _deadAnimation = selectRandom _deadAnimations;

    while { alive _unit && lifeState _unit == "INCAPACITATED" } do {
        if (animationState _unit != _deadAnimation) then {
            [_unit, [_deadAnimation]] remoteExec ["switchMove", 0];
        };
        if (_unit distance2D _originalDeathPos > 30) then {
            _unit setPosWorld _originalDeathPos;
            _unit setVelocity [0, 0, 0];
        };

        uiSleep 1;
        if (serverTime - _downedTime > 90) then {
            deleteVehicle _unit;
            break;
        };
    };
};
[_unit, _source, _instigator] remoteExec ["WL2_fnc_handleEntityRemoval", 2];
0.99;