#include "includes.inc"
params ["_sender", "_targetUid", "_reason", "_time"];

if (isNull _sender) exitWith {};
if !(isServer) exitWith {};
if (remoteExecutedOwner != owner _sender) exitWith {};

private _uid = getPlayerUID _sender;
private _isAdmin = _uid in (getArray (missionConfigFile >> "adminIDs"));
private _isModerator = _uid in (getArray (missionConfigFile >> "moderatorIDs"));
if !(_isAdmin || _isModerator || _uid == _targetUid) exitWith {};

private _punishIncident = [serverTime + _time, _reason];
private _punishmentMap = missionNamespace getVariable ["WL2_punishmentMap", createHashMap];
_punishmentMap set [_targetUid, _punishIncident];
missionNamespace setVariable ["WL2_punishmentMap", _punishmentMap, true];

private _punishedPlayer = _targetUid call BIS_fnc_getUnitByUID;
[_punishIncident] remoteExec ["WL2_fnc_punishmentClient", _punishedPlayer];