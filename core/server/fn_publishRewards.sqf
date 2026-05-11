#include "includes.inc"
params ["_uid"];

private _moneyHistory = serverNamespace getVariable "moneyHistory";
private _playerData = _moneyHistory getOrDefault [_uid, []];

[_playerData] remoteExec ["WL2_fnc_writeResult", remoteExecutedOwner];