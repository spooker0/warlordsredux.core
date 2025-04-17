if !(isServer) exitWith {};

params ["_amount", "_uid"];

private _readyList = missionNamespace getVariable ["WL2_readyList", []];
if !(_uid in _readyList) exitWith {};
if (_uid == "") exitWith {};

private _fundsDB = (serverNamespace getVariable "fundsDatabase");
private _playerFunds = _fundsDB getOrDefault [_uid, 0];

private _dbAmount = (_playerFunds + _amount) min 50000;
_fundsDB set [_uid, _dbAmount];

[_fundsDB, _uid] call WL2_fnc_fundsDatabaseUpdate;