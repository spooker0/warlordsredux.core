#include "includes.inc"
params ["_uid", "_funds"];

if (!hasInterface) exitWith {};
if (isRemoteExecuted && remoteExecutedOwner != 2) exitWith {};

private _database = missionNamespace getVariable ["fundsDatabaseClients", createHashMap];
_database set [_uid, _funds];
missionNamespace setVariable ["fundsDatabaseClients", _database];