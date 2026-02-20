#include "includes.inc"
params ["_sender", "_targetUid"];

if (isNull _sender) exitWith {};
if !(isServer) exitWith {};
if (remoteExecutedOwner != owner _sender) exitWith {};

#if WL_STOP_TEAM_SWITCH
private _uid = getPlayerUID _sender;
private _isAdmin = _uid in (getArray (missionConfigFile >> "adminIDs"));
private _isModerator = _uid in (getArray (missionConfigFile >> "moderatorIDs"));
if !(_isAdmin || _isModerator) exitWith {};
#endif

private _playerList = serverNamespace getVariable ["playerList", createHashMap];
private _currentSide = _playerList getOrDefault [_targetUid, sideUnknown];
private _newSide = if (_currentSide == west) then { east } else { west };
_playerList set [_targetUid, _newSide];

private _rebalancedPlayer = [_targetUid] call BIS_fnc_getUnitByUID;

private _lockTeamName = if (_newSide == west) then { "BLUFOR" } else { "OPFOR" };
private _message = format ["You have been rebalanced to %1. Rejoin from lobby.", _lockTeamName];
[_rebalancedPlayer, _message] remoteExec ["WL2_fnc_rebalanced", _rebalancedPlayer];

private _ownedVehiclesVar = format ["BIS_WL_ownedVehicles_%1", _targetUid];
private _ownedVehicles = missionNamespace getVariable [_ownedVehiclesVar, []];
_ownedVehicles = _ownedVehicles select { alive _x };
{
    if (unitIsUAV _x) then {
        private _group = group effectiveCommander _x;
        {
            _x deleteVehicleCrew _x;
        } forEach crew _x;
        deleteGroup _group;
    };

    deleteVehicle _x;
} forEach _ownedVehicles;
missionNamespace setVariable [_ownedVehiclesVar, []];