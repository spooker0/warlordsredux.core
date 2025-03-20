params ["_stronghold", "_protect"];

if (_stronghold isKindOf "House" || _stronghold isKindOf "Building") then {
    _stronghold allowDamage !(_protect);
};

if (!_protect) then {
    private _strongholdActions = actionIDs _stronghold;
    if (isNil "_strongholdActions") exitWith {};
    {
        [_stronghold, _x] call BIS_fnc_holdActionRemove;
    } forEach _strongholdActions;
    _stronghold setVariable ["WL_strongholdSector", objNull, true];
};

_stronghold setVariable ["WL2_canDemolish", _protect, true];