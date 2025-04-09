params ["_sender", "_targetUid", "_reason", "_time"];

if (isNull _sender) exitWith {};
if !(isServer) exitWith {};
if (remoteExecutedOwner != owner _sender) exitWith {};

private _uid = getPlayerUID _sender;
private _isAdmin = _uid in (getArray (missionConfigFile >> "adminIDs"));
private _isModerator = _uid in (getArray (missionConfigFile >> "moderatorIDs"));
if !(_isAdmin || _isModerator) exitWith {};

_time = _time min (30 * 60);

private _punishVar = format ["WL2_punish_%1", _targetUid];
private _punishIncident = [serverTime + _time, _reason];
serverNamespace setVariable [_punishVar, _punishIncident];

private _punishedPlayer = _targetUid call BIS_fnc_getUnitByUID;
[_punishIncident] remoteExec ["WL2_fnc_punishmentClient", _punishedPlayer];