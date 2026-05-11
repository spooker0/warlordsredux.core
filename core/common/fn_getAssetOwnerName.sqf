#include "includes.inc"
params ["_asset"];
private _cachedName = _asset getVariable ["WL2_assetOwnerName", ""];
if (_cachedName != "") exitWith {
    _cachedName;
};

private _ownerPlayer = (_asset getVariable ["BIS_WL_ownerAsset", "123"]) call BIS_fnc_getUnitByUID;
private _ownerName = name _ownerPlayer;
if (_ownerName == "Error: No vehicle") then {
    private _side = [_asset] call WL2_fnc_getAssetSide;
    _ownerName = [_side] call WL2_fnc_sideToFaction;
};
if (_ownerName != "Error: No vehicle") then {
    _asset setVariable ["WL2_assetOwnerName", _ownerName];
};
_ownerName