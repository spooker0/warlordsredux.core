#include "includes.inc"
params ["_asset", "_unit"];

private _accessControl = _asset getVariable ["WL2_accessControl", 0];
if (_accessControl == 0) exitWith {
    [true, ""];
};
if (_accessControl == 1) exitWith {
    [false, localize "STR_WL_accessDenied"];
};
if (_accessControl != 2 && _accessControl != 3) exitWith {
    [false, localize "STR_WL_accessDenied"];
};

if (side group _unit != [_asset] call WL2_fnc_getAssetSide) exitWith {
    [false, localize "STR_WL_enemyVehicleClaim"];
};
if (_accessControl == 3) exitWith {
    [true, ""];
};

private _ownerUid = _asset getVariable ["BIS_WL_ownerAsset", "123"];
private _isOwner = getPlayerUID _unit == _ownerUid;
[_isOwner, localize "STR_WL_vehicleLockedReason"];