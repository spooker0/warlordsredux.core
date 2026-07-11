#include "includes.inc"
params ["_category", "_class"];

if (_category != "Air Defense") exitWith {
    [true, ""]
};

private _assetCost = WL_ASSET(_class, "cost", 0);
if (_assetCost <= 4000) exitWith {
    [true, ""]
};

private _enemyUnits = switch (BIS_WL_playerSide) do {
    case west: { BIS_WL_eastOwnedVehicles + BIS_WL_guerOwnedVehicles };
    case east: { BIS_WL_westOwnedVehicles + BIS_WL_guerOwnedVehicles };
    case independent: { BIS_WL_westOwnedVehicles + BIS_WL_eastOwnedVehicles };
    default { [] };
};

private _entitiesInRange = _enemyUnits select {
    alive _x
} select {
    WL_UNIT(_x, "cost", 0) >= 8000
} select {
    private _posAGL = _x modelToWorld [0, 0, 0];
    _posAGL # 2 > 20
} select {
    player distance _x < 3500
};

if (count _entitiesInRange > 0) then {
    [false, "Cannot deploy heavy air defense in contested airspace."]
} else {
    [true, ""]
};