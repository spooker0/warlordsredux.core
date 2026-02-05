#include "includes.inc"
params ["_side", "_area", ["_detectGreen", true]];

private _greenUnits = if (_detectGreen) then {
    BIS_WL_guerOwnedVehicles
} else {
    [];
};

private _enemyUnits = switch (_side) do {
    case west: { BIS_WL_eastOwnedVehicles + _greenUnits };
    case east: { BIS_WL_westOwnedVehicles + _greenUnits };
    default { [] };
};

(_enemyUnits inAreaArray _area)
    select { _x getVariable ["WL_spawnedAsset", false] || isPlayer _x }
    select { alive _x }
    select { vehicle _x == _x }
    select { [_x] call WL2_fnc_getAssetSide != _side };