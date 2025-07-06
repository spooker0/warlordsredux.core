#include "includes.inc"
params ["_unitUid"];
if (isDedicated) exitWith {};

private _killedMap = missionNamespace getVariable ["WL2_killed", createHashMap];
_timesKilled = _killedMap getOrDefault [_unitUid, 0];
_timesKilled = _timesKilled + 1;
_killedMap set [_unitUid, _timesKilled];
missionNamespace setVariable ["WL2_killed", _killedMap];