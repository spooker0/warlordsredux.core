#include "includes.inc"
private _lastSelectedLoadoutIndex = uiNamespace getVariable ["WLM_lastSelectedLoadoutIndex", -1];

if (_lastSelectedLoadoutIndex == -1) exitWith {
    ["Select a loadout first."] call WL2_fnc_smoothText;
    playSoundUI ["AddItemFailed"];
};

private _asset = uiNamespace getVariable "WLM_asset";

private _assetActualType = WL_ASSET_TYPE(_asset);
private _vehicleLoadouts = missionProfileNamespace getVariable ["WL2_vehicleLoadouts", createHashMap];
private _savedLoadouts = _vehicleLoadouts getOrDefault [_assetActualType, []];

private _selectedLoadout = _savedLoadouts select _lastSelectedLoadoutIndex;

private _display = findDisplay WLM_DISPLAY;
_display closeDisplay 0;

private _message = format [localize "STR_WL_wipeLoadoutWarning", _selectedLoadout # 0];
private _results = [localize "STR_WL_wipeLoadout", _message, "Delete", "Cancel"] call WL2_fnc_prompt;

if (_results) then {
    uiNamespace setVariable ["WLM_lastSelectedLoadoutIndex", -1];
    playSoundUI ["AddItemOK"];
    _savedLoadouts deleteAt _lastSelectedLoadoutIndex;
    _vehicleLoadouts set [_assetActualType, _savedLoadouts];
    missionProfileNamespace setVariable ["WL2_vehicleLoadouts", _vehicleLoadouts];
};