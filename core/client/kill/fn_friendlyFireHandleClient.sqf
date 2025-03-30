params ["_friendlyFireIncidents"];

private _incidentCount = count _friendlyFireIncidents;

if (_incidentCount < 3) exitWith {};

// Ensure that the last 3 were committed within 30 minutes
private _lastIncident = _friendlyFireIncidents # (_incidentCount - 1);
private _threeIncidentsAgo = _friendlyFireIncidents # (_incidentCount - 3);
if (_lastIncident - _threeIncidentsAgo > 30 * 60) exitWith {};

private _message = format ["%1 has been temporarily kicked/blocked from the game for teamkilling.", name player];
[name player] remoteExec ["WL2_fnc_teamkillerMessage", 0];

private _penaltyEnd = _lastIncident + 30 * 60;

private _timeRemaining = [(_penaltyEnd - serverTime) max 0, "MM:SS"] call BIS_fnc_secondsToString;
private _penaltyText = format ["You are blocked from rejoining the game for %1.", _timeRemaining];

"BlockScreen" setDebriefingText ["Punished", _penaltyText, "Friendly fire punished."];
endMission "BlockScreen";
forceEnd;