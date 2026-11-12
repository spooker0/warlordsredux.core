#include "includes.inc"
closeDialog 0;

private _result = [localize "STR_WL_resetAll", localize "STR_WL_resetAllConfirm", localize "STR_WL_yes", localize "STR_WL_cancel"] call WL2_fnc_prompt;
if (!_result) exitWith {};

missionProfileNamespace setVariable ["WL2_settings", createHashMap];
[localize "STR_WL_allSettingsResetDefault"] call WL2_fnc_smoothText;
playSoundUI ["AddItemOK"];