#include "includes.inc"
params ["_asset", "_lockActionId"];

private _isUAV = unitIsUAV _asset;
private _accessControl = _asset getVariable ["WL2_accessControl", 0];

(_accessControl call WL2_fnc_getVehicleLockStatus) params ["_color", "_lockLabel"];

private _lockIcon = "a3\modules_f\data\iconunlock_ca.paa";
_asset setUserActionText [_lockActionId, format ["<t color='%1'>%2</t>", _color, _lockLabel], format ["<img size='2' image='%1'/>", _lockIcon]];

_asset call WL2_fnc_uavConnectRefresh;