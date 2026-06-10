#include "includes.inc"
private _lastSelectedLoadoutIndex = uiNamespace getVariable ["WLM_lastSelectedLoadoutIndex", -1];

if (_lastSelectedLoadoutIndex == -1) exitWith {
    ["Select a loadout first."] call WL2_fnc_smoothText;
    playSoundUI ["AddItemFailed"];
};

private _asset = uiNamespace getVariable "WLM_asset";

private _assetActualType = WL_ASSET_TYPE(_asset);
private _variableName = format ["WLM_savedLoadout_%1", _assetActualType];
private _savedLoadouts = profileNamespace getVariable [_variableName, []];

private _selectedLoadout = _savedLoadouts select _lastSelectedLoadoutIndex;

private _message = format [localize "STR_WL_wipeLoadoutWarning", _selectedLoadout # 0];
private _results = [localize "STR_WL_wipeLoadout", _message, "Delete", "Cancel"] call WL2_fnc_prompt;

if (_results) then {
    uiNamespace setVariable ["WLM_lastSelectedLoadoutIndex", -1];
    playSoundUI ["AddItemOK"];
    _savedLoadouts deleteAt _lastSelectedLoadoutIndex;
    profileNamespace setVariable [_variableName, _savedLoadouts];
    call WLM_fnc_constructPresetMenu;
};