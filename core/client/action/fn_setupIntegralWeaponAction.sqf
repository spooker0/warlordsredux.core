#include "includes.inc"
params ["_asset"];

_asset addAction [
    format ["<t color='#00ff00'>Deploy Integral Weapon (%1)</t>", (actionKeysNames "deployWeaponAuto") regexReplace ["""", ""]],
    { _this spawn WL2_fnc_integralWeaponAction; },
    nil,
    6,
    false,
    false,
    "deployWeaponAuto",
    "driver _target == _this",
    WL_MAINTENANCE_RADIUS,
    false
];