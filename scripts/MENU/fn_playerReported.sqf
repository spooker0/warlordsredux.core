#include "includes.inc"
params ["_senderName", "_reason"];

private _playerReports = missionProfileNamespace getVariable ["WL2_playerReports", createHashMap];
_playerReports set [_senderName, [_reason, systemTimeUTC]];
missionProfileNamespace setVariable ["WL2_playerReports", _playerReports];