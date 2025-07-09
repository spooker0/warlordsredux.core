#include "includes.inc"
params ["_stronghold", "_protect"];

if (isNil "_stronghold" || isNull _stronghold) exitWith {};

if (_stronghold isKindOf "House" || _stronghold isKindOf "Building") then {
    _stronghold allowDamage !(_protect);
};

_stronghold setVariable ["WL2_canDemolish", _protect, true];