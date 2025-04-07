#include "..\..\warlords_constants.inc"

params ["_category", "_class"];

if (_category != "Air Defense") exitWith {
    [true, ""]
};

private _costMap = missionNamespace getVariable ["WL2_costs", createHashMap];
private _assetCost = _costMap getOrDefault [_class, 0];

if (_assetCost <= 1000) exitWith {
    [true, ""]
};

private _entitiesInRange = player nearEntities ["Air", 3500];
_entitiesInRange = _entitiesInRange select {
    private _assetActualType = _x getVariable ["WL2_orderedClass", typeOf _x];
    private _assetCost = _costMap getOrDefault [_assetActualType, 0];
    private _height = (getPosASL _x # 2) min (getPosATL _x # 2);
    private _isEnemy = ([_x] call WL2_fnc_getAssetSide) != (side group player);
    alive _x && _assetCost >= 8000 && _height > 20 && _isEnemy
};

if (count _entitiesInRange > 0) then {
    [false, "Cannot deploy heavy air defense in contested airspace."]
} else {
    [true, ""]
};