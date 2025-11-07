#include "includes.inc"
if !(isServer) exitWith {};

params ["_amount", "_uid", ["_countAsTeamEarning", true]];

private _readyList = missionNamespace getVariable ["WL2_readyList", []];
if !(_uid in _readyList) exitWith {};
if (_uid == "") exitWith {};

private _fundsDB = (serverNamespace getVariable "fundsDatabase");
private _playerFunds = _fundsDB getOrDefault [_uid, 0];

private _dbAmount = (_playerFunds + _amount) min WL_MAX_MONEY;
_fundsDB set [_uid, _dbAmount];

[_fundsDB, _uid] call WL2_fnc_fundsDatabaseUpdate;

if (_amount > 0 && _countAsTeamEarning) then {
    ["earnPoints", [_uid, _amount]] call SQD_fnc_server;
};

private _missionSpectators = missionNamespace getVariable ["WL2_spectators", []];
{
    private _targetUid = _x getVariable ["SPEC_CameraTargetUid", "123"];
    if (_targetUid == _uid) then {
        [_amount] remoteExec ["SPEC_fnc_spectatorRewardProxy", _x];
    };
} forEach _missionSpectators;