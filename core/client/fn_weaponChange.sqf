#include "includes.inc"
params ["_asset"];

_asset addEventHandler ["WeaponChanged", {
    params ["_asset"];
    [_asset] call WL2_fnc_ammoConfigDetection;
}];