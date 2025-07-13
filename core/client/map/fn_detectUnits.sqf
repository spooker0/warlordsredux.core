#include "includes.inc"
params ["_side", "_area"];

((allUnits + vehicles) inAreaArray _area)
    select { _x getVariable ["WL_spawnedAsset", false] || isPlayer _x }
    select { alive _x }
    select { vehicle _x == _x }
    select { [_x] call WL2_fnc_getAssetSide != _side };