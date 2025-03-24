params ["_side", "_area"];

((allUnits + vehicles) inAreaArray _area) select {
    alive _x &&
    [_x] call WL2_fnc_getAssetSide != _side &&
    !(_x isKindOf "Logic") &&
    !(_x isKindOf "WeaponHolderSimulated") &&
    vehicle _x == _x
};