params ["_stronghold", "_protect"];

if (_stronghold isKindOf "House" || _stronghold isKindOf "Building") then {
    _stronghold allowDamage !(_protect);
};

if (_protect) then {
    [_stronghold] call WL2_fnc_demolish;
} else {
    private _strongholdActions = actionIDs _stronghold;
    {
        [_stronghold, _x] call BIS_fnc_holdActionRemove;
    } forEach _strongholdActions;
};