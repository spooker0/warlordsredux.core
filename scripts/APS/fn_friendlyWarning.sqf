#include "includes.inc"
params ["_player"];
if (isDedicated) exitWith {};
[format [localize "STR_WL_apsFriendlyFireWarning", _player]] call WL2_fnc_smoothText;

private _settingsMap = missionProfileNamespace getVariable ["WL2_settings", createHashMap];
private _apsVolume = _settingsMap getOrDefault ["apsVolume", 1];

playSoundUI ["a3\sounds_f\sfx\alarm_3.wss", _apsVolume];