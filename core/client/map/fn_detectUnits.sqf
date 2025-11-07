#include "includes.inc"
params ["_side", "_area"];

private _enemyUnits = switch (_side) do {
    case west: { BIS_WL_westOwnedVehicles + BIS_WL_guerOwnedVehicles };
    case east: { BIS_WL_eastOwnedVehicles + BIS_WL_guerOwnedVehicles };
    default { [] };
};

(_enemyUnits inAreaArray _area)
    select { _x getVariable ["WL_spawnedAsset", false] || isPlayer _x }
    select { alive _x }
    select { vehicle _x == _x }
    select { [_x] call WL2_fnc_getAssetSide != _side };