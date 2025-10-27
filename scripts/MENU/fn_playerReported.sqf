#include "includes.inc"
params ["_senderName", "_reason"];

private _playerReports = profileNamespace getVariable ["WL2_playerReports", createHashMap];
_playerReports set [_senderName, [_reason, systemTimeUTC]];
profileNamespace setVariable ["WL2_playerReports", _playerReports];