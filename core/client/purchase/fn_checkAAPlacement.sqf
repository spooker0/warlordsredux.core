#include "includes.inc"
params ["_category", "_class"];

if (_category != "Air Defense") exitWith {
    [true, ""]
};

private _assetCost = WL_ASSET(_class, "cost", 0);
if (_assetCost <= 2000) exitWith {
    [true, ""]
};

private _entitiesInRange = player nearEntities ["Air", 3500];
_entitiesInRange = _entitiesInRange select {
    alive _x
} select {
    [_x] call WL2_fnc_getAssetSide != side group player
} select {
    WL_UNIT(_x, "cost", 0) >= 8000
} select {
    private _posAGL = _x modelToWorld [0, 0, 0];
    _posAGL # 2 > 20
};

if (count _entitiesInRange > 0) then {
    [false, "Cannot deploy heavy air defense in contested airspace."]
} else {
    [true, ""]
};