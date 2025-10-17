#include "includes.inc"
params ["_asset"];

private _ownerPlayer = (_asset getVariable ["BIS_WL_ownerAsset", "123"]) call BIS_fnc_getUnitByUID;
if (name _ownerPlayer == "Error: No vehicle") then {
    private _side = [_asset] call WL2_fnc_getAssetSide;
    [_side] call WL2_fnc_sideToFaction;
} else {
    name _ownerPlayer;
};