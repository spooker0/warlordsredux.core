params ["_newLevel"];

systemChat format ["You have reached level %1!", _newLevel];

private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];
private _musicSound = _settingsMap getOrDefault ["levelUpMusic", 0.8];

private _sound = playSoundUI ["a3\music_f_tank\leadtrack06_f_tank.ogg", _musicSound, 1, true, 0.5];
0 spawn WL2_fnc_updateLevelDisplay;
sleep 12.5;
stopSound _sound;