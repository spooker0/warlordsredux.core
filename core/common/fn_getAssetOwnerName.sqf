#include "includes.inc"
params ["_asset"];

private _ownerPlayer = (_asset getVariable ["BIS_WL_ownerAsset", "123"]) call BIS_fnc_getUnitByUID;
if (name _ownerPlayer == "Error: No vehicle") then {
    "?";
} else {
    name _ownerPlayer;
};