#include "includes.inc"
params ["_projectile"];

if (isNull (missileTarget _projectile)) exitWith {};
private _target = missileTarget _projectile;
if !(_target isKindOf "Air") exitWith {};

private _sequence = 0;
while { alive _projectile } do {
    _projectile setVariable ["APS_heartbeat", -1];
    [_projectile, _sequence] remoteExec ["APS_fnc_lagProtectionServer", 2];

    uiSleep 2;

    if ((_projectile getVariable ["APS_heartbeat", -1]) != _sequence) then {
        deleteVehicle _projectile;
        ["Lag Protection: Projectile deleted due to lag."] call WL2_fnc_smoothText;
        break;
    };
    _sequence = _sequence + 1;
};