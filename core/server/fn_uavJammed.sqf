#include "includes.inc"
params ["_uav", "_jammer"];

private _damageAdd = if (_uav getVariable ["WL2_isFragileDrone", false]) then {
    1
} else {
    0.25
};

_uav setDamage [damage _uav + _damageAdd, true, _jammer, _jammer];