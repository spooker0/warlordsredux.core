#include "includes.inc"
params ["_uav", "_jammer"];

private _damageAdd = if (_uav isKindOf "UAV_06_base_F") then {
    1
} else {
    0.1
};

_uav setDamage [damage _uav + _damageAdd, true, _jammer, _jammer];