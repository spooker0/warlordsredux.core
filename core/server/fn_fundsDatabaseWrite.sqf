if !(isServer) exitWith {};

params ["_amount"];

private _incomeBlocked = serverNamespace getVariable ["WL2_afkList", []];
if (_uid in _incomeBlocked) then {
    _amount = _amount min 0;
};

private _readyList = missionNamespace getVariable ["WL2_readyList", []];
if !(_uid in _readyList) exitWith {};

if (isNil {_uid}) exitWith {};

private _fundsDB = (serverNamespace getVariable "fundsDatabase");
private _playerFunds = _fundsDB getOrDefault [_uid, 0];

private _dbAmount = (_playerFunds + _amount) min 50000;
_fundsDB set [_uid, _dbAmount];

_fundsDB call WL2_fnc_fundsDatabaseUpdate;