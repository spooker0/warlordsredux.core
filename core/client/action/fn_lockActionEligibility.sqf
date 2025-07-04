#include "includes.inc"
params ["_target", "_caller"];

if (!alive _target) exitWith {
    false
};

private _playerUid = getPlayerUID _caller;
private _targetOwnerUid = _target getVariable ['BIS_WL_ownerAsset', '123'];

if (_playerUid != _targetOwnerUid) exitWith {
    false
};

if (cursorObject != _target && vehicle _caller != _target) exitWith {
    false
};

true;