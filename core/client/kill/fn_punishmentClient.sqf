params ["_punishIncident"];

private _uid = getPlayerUID player;
private _isAdmin = _uid in (getArray (missionConfigFile >> "adminIDs"));
private _isModerator = _uid in (getArray (missionConfigFile >> "moderatorIDs"));
if (_isAdmin || _isModerator) exitWith {};

if (count _punishIncident == 0) exitWith {};

private _punishEndTime = _punishIncident # 0;
private _punishReason = _punishIncident # 1;

if (_punishEndTime < serverTime) exitWith {};

private _timeRemaining = [(_punishEndTime - serverTime) max 0, "MM:SS"] call BIS_fnc_secondsToString;
private _penaltyText = format ["You are blocked from rejoining the game for %1.", _timeRemaining];

[name player, _timeRemaining, _punishReason] remoteExec ["WL2_fnc_punishMessage", 0];

"BlockScreen" setDebriefingText ["Punished", _penaltyText, format ["Reason: %1", _punishReason]];
endMission "BlockScreen";
forceEnd;