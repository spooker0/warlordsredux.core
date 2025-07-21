#include "includes.inc"
params ["_sender", "_targetUid"];

if (isNull _sender) exitWith {};
if !(isServer) exitWith {};
if (remoteExecutedOwner != owner _sender) exitWith {};

private _uid = getPlayerUID _sender;
private _isAdmin = _uid in (getArray (missionConfigFile >> "adminIDs"));
private _isModerator = _uid in (getArray (missionConfigFile >> "moderatorIDs"));
if !(_isAdmin || _isModerator) exitWith {};

// private _ownedVehicleVar = format ["BIS_WL_ownedVehicles_%1", _targetUid];
// private _ownedVehicles = missionNamespace getVariable [_ownedVehicleVar, []];
// private _assetValueSum = 0;
// {
//     private _assetActualType = _x getVariable ["WL2_orderedClass", typeOf _x];
//     _assetValueSum = _assetValueSum + WL_ASSET(_assetActualType, "cost", 0);
// } forEach _ownedVehicles;
// if (_assetValueSum > 10000 && _isModerator) exitWith {};

private _playerList = serverNamespace getVariable ["playerList", createHashMap];
private _currentSide = _playerList getOrDefault [_targetUid, sideUnknown];
if (_currentSide == west) then {
    _playerList set [_targetUid, east];
} else {
    _playerList set [_targetUid, west];
};

private _punishedPlayer = _targetUid call BIS_fnc_getUnitByUID;
[[serverTime + 10, "team balance"]] remoteExec ["WL2_fnc_punishmentClient", _punishedPlayer];