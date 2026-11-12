#include "includes.inc"
params ["_newLevel"];

[format [localize "STR_WL_reachedLevel", _newLevel]] call WL2_fnc_smoothText;

private _settingsMap = missionProfileNamespace getVariable ["WL2_settings", createHashMap];
private _musicSound = _settingsMap getOrDefault ["levelUpMusic", 0.8];

private _sound = playSoundUI ["a3\music_f_tank\leadtrack06_f_tank.ogg", _musicSound, 1, true, 0.5];
0 spawn WL2_fnc_updateLevelDisplay;
uiSleep 12.5;
stopSound _sound;