#include "includes.inc"
params ["_asset", "_applyTextures", ["_save", true]];

_asset = if (_asset isEqualTo objNull) then {
    uiNamespace getVariable "WLM_asset"
} else {
    _asset
};

private _assetActualType = WL_ASSET_TYPE(_asset);

if (_save) then {
    private _appearanceDefaults = missionProfileNamespace getVariable ["WL2_appearanceDefaults", createHashmap];
    private _assetAppearanceDefaults = _appearanceDefaults getOrDefault [_assetActualType, createHashmap];
    _assetAppearanceDefaults set ["camo", _applyTextures];
    _appearanceDefaults set [_assetActualType, _assetAppearanceDefaults];
    missionProfileNamespace setVariable ["WL2_appearanceDefaults", _appearanceDefaults];
};

{
    _asset setObjectTextureGlobal [_x, _y];
} forEach _applyTextures;
