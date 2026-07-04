#include "includes.inc"
params ["_position"];
private _lastPlayed = missionNamespace getVariable ["WL2_lastArrivalSoundPlayed", 0];
if (serverTime - _lastPlayed < 5) exitWith {};
private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];
private _spawnNearbyVolume = _settingsMap getOrDefault ["spawnNearbyVolume", 1];
missionNamespace setVariable ["WL2_lastArrivalSoundPlayed", serverTime];
playSound3D ["a3\data_f_curator\sound\cfgsounds\moduleseagulls.wss", objNull, false, _position, 2 * _spawnNearbyVolume, 1, 0, 0, true];

["(Disturbed birds nearby.)", true] call WL2_fnc_smoothText;