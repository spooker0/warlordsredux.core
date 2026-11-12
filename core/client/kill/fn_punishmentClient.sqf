#include "includes.inc"
params ["_punishIncident"];

private _uid = getPlayerUID player;
private _isAdmin = _uid in (getArray (missionConfigFile >> "adminIDs"));
if (_isAdmin) exitWith {};

if (count _punishIncident == 0) exitWith {};

private _punishEndTime = _punishIncident # 0;
private _punishReason = _punishIncident # 1;

if (_punishEndTime < serverTime) exitWith {};

private _timeRemaining = [(_punishEndTime - serverTime) max 0, "HH:MM:SS"] call BIS_fnc_secondsToString;

[name player, _timeRemaining, _punishReason] remoteExec ["WL2_fnc_punishMessage", 0];

["main"] call BIS_fnc_endLoadingScreen;

if ("kick" in _punishReason || "cheat" in _punishReason) exitWith {
    private _penaltyText = format [
        localize "STR_WL_punishedBlockText",
        _timeRemaining
    ];
    "BlockScreen" setDebriefingText [localize "STR_WL_punishedTitle", _penaltyText, format [localize "STR_WL_punishedReason", _punishReason]];
    endMission "BlockScreen";
    forceEnd;
};

[_punishEndTime, _punishReason] spawn WL2_fnc_gulag;