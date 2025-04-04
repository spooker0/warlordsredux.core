params ["_stronghold", "_protect"];

if (_stronghold isKindOf "House" || _stronghold isKindOf "Building") then {
    _stronghold allowDamage !(_protect);
};

_stronghold setVariable ["WL2_canDemolish", _protect, true];