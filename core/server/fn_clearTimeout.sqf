#include "includes.inc"
params ["_sender", "_targetUid"];

if (isNull _sender) exitWith {};
if !(isServer) exitWith {};
if (remoteExecutedOwner != owner _sender) exitWith {};

private _uid = getPlayerUID _sender;
private _isAdmin = _uid in (getArray (missionConfigFile >> "adminIDs"));
private _isModerator = _uid in (getArray (missionConfigFile >> "moderatorIDs"));
if !(_isAdmin || _isModerator) exitWith {};

private _playerList = serverNamespace getVariable ["playerList", createHashMap];

private _punishVar = format ["WL2_punish_%1", _targetUid];
private _punishment = serverNamespace getVariable [_punishVar, []];
if (count _punishment > 0) then {
    serverNamespace setVariable [_punishVar, []];
    private _punishmentCollection = missionNamespace getVariable ["WL2_punishmentCollection", createHashMap];
    _punishmentCollection deleteAt _targetUid;
    missionNamespace setVariable ["WL2_punishmentCollection", _punishmentCollection, true];
};