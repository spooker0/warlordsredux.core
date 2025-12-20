#include "includes.inc"
params ["_exitTitle", "_exitSubtitle"];

private _uid = getPlayerUID player;
private _isAdmin = _uid in (getArray (missionConfigFile >> "adminIDs"));
if (_isAdmin) exitWith {};

["main"] call BIS_fnc_endLoadingScreen;

"BlockScreen" setDebriefingText ["Exit to Lobby", _exitTitle, _exitSubtitle];
endMission "BlockScreen";
forceEnd;