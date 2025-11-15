#include "includes.inc"
params ["_uav", "_jammer"];

private _damageAdd = if (_uav getVariable ["WL2_isBombDrone", false]) then {
    1
} else {
    0.1
};

_uav setDamage [damage _uav + _damageAdd, true, _jammer, _jammer];