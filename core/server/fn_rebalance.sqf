params ["_sender", "_targetUid"];

if (isNull _sender) exitWith {};
if !(isServer) exitWith {};
if (remoteExecutedOwner != owner _sender) exitWith {};

private _uid = getPlayerUID _sender;
private _isAdmin = _uid in (getArray (missionConfigFile >> "adminIDs"));
private _isModerator = _uid in (getArray (missionConfigFile >> "moderatorIDs"));
if !(_isAdmin || _isModerator) exitWith {};

private _playerList = serverNamespace getVariable ["playerList", createHashMap];
private _currentSide = _playerList getOrDefault [_targetUid, sideUnknown];
if (_currentSide == west) then {
    _playerList set [_targetUid, east];
} else {
    _playerList set [_targetUid, west];
};

private _punishedPlayer = _targetUid call BIS_fnc_getUnitByUID;
[[serverTime + 10, "team balance"]] remoteExec ["WL2_fnc_punishmentClient", _punishedPlayer];