#include "includes.inc"
params ["_target", "_caller"];

if (!alive _target) exitWith { false };
if (WL_ISDOWN(_caller)) exitWith { false };

private _accessControl = _target getVariable ["WL2_accessControl", 0];
if (_accessControl != 2 && _accessControl != 3) exitWith {
    false
};

private _ownerUid = _target getVariable ["BIS_WL_ownerAsset", "123"];
if (getPlayerUID _caller != _ownerUid) exitWith {
    false
};

cameraOn == _target