#include "includes.inc"
params ["_sender", "_targetUid", "_reason", "_time"];

if (isNull _sender) exitWith {};
if !(isServer) exitWith {};
if (remoteExecutedOwner != owner _sender) exitWith {};

private _uid = getPlayerUID _sender;
private _isAdmin = _uid in (getArray (missionConfigFile >> "adminIDs"));
private _isModerator = _uid in (getArray (missionConfigFile >> "moderatorIDs"));
if !(_isAdmin || _isModerator || _uid == _targetUid) exitWith {};

// private _ownedVehicleVar = format ["BIS_WL_ownedVehicles_%1", _targetUid];
// private _ownedVehicles = missionNamespace getVariable [_ownedVehicleVar, []];
// private _assetValueSum = 0;
// {
//     private _assetActualType = _x getVariable ["WL2_orderedClass", typeOf _x];
//     _assetValueSum = _assetValueSum + WL_ASSET(_assetActualType, "cost", 0);
// } forEach _ownedVehicles;
// if (_assetValueSum > 10000 && _isModerator) exitWith {};

// _time = _time min (30 * 60);

private _punishVar = format ["WL2_punish_%1", _targetUid];
private _punishIncident = [serverTime + _time, _reason];
serverNamespace setVariable [_punishVar, _punishIncident];

private _punishmentCollection = missionNamespace getVariable ["WL2_punishmentCollection", []];
_punishmentCollection pushBack [_targetUid, serverTime + _time];
missionNamespace setVariable ["WL2_punishmentCollection", _punishmentCollection, true];

private _punishedPlayer = _targetUid call BIS_fnc_getUnitByUID;
[_punishIncident] remoteExec ["WL2_fnc_punishmentClient", _punishedPlayer];