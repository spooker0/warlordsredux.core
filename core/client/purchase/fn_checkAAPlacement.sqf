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
    private _assetActualType = _x getVariable ["WL2_orderedClass", typeOf _x];
    private _entityCost = WL_ASSET(_assetActualType, "cost", 0);
    private _height = (getPosASL _x # 2) min (getPosATL _x # 2);
    private _isEnemy = ([_x] call WL2_fnc_getAssetSide) != (side group player);
    alive _x && _entityCost >= 8000 && _height > 20 && _isEnemy
};

if (count _entitiesInRange > 0) then {
    [false, "Cannot deploy heavy air defense in contested airspace."]
} else {
    [true, ""]
};