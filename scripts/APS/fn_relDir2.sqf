#include "includes.inc"
params ["_incomingDirection", "_vehicle"];

_incomingDirection = _incomingDirection - 180;
if(_incomingDirection < 0) then{
    _incomingDirection = _incomingDirection + 360
};

private _weaponDirection = [_vehicle] call APS_fnc_getDirection;
private _relativeDirection = _incomingDirection - _weaponDirection;

if(_relativeDirection < 0) then {
    _relativeDirection = _relativeDirection + 360
};
_relativeDirection;