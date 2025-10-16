#include "includes.inc"
params ["_player"];
if (isDedicated) exitWith {};
systemChat format ["Warning: APS friendly fire detected from %1.", _player];

private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];
private _apsVolume = _settingsMap getOrDefault ["apsVolume", 1];

playSoundUI ["a3\sounds_f\sfx\alarm_3.wss", _apsVolume];