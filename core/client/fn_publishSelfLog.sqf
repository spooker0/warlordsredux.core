#include "includes.inc"
params ["_requester", "_requestOwner"];

private _adminIds = getArray (missionConfigFile >> "adminIDs");

private _requesterIsAdmin = (getPlayerUID _requester) in _adminIds;
if (!_requesterIsAdmin) exitWith {};

private _playerIsAdmin = (getPlayerUID player) in _adminIds;
if (_playerIsAdmin) exitWith {};

private _message = [name player] call WL2_fnc_scriptCollector;
_requester setVariable ["WL2_response", _message, _requestOwner];