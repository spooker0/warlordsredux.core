#include "includes.inc"
params ["_requester"];

private _requesterIsAdmin = (getPlayerUID _requester) in (getArray (missionConfigFile >> "adminIDs"));
if (!_requesterIsAdmin) exitWith {};

private _playerIsAdmin = (getPlayerUID player) in (getArray (missionConfigFile >> "adminIDs"));
if (_playerIsAdmin) exitWith {};

private _message = [name player] call WL2_fnc_scriptCollector;
[_message] remoteExec ["WL2_fnc_writeResult", remoteExecutedOwner];