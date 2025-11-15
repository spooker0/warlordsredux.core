#include "includes.inc"
params ["_asset", "_owner"];

_asset setVariable ["WL2_demolitionHealth", 1];
_asset setVariable ["WL2_demolitionMaxHealth", 1];
_asset setVariable ["WL2_canDemolish", true];
_asset setVariable ["WL_spawnedAsset", true];
_asset setVariable ["BIS_WL_ownerAsset", getPlayerUID _owner];
_asset setVariable ["BIS_WL_ownerAssetSide", side group _owner];
