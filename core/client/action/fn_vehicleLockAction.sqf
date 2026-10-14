#include "includes.inc"
params ["_asset", ["_newAccess", -1], ["_playSound", true]];

private _accessControl = _asset getVariable ["WL2_accessControl", 0];
if (_accessControl != 2 && _accessControl != 3) exitWith {};

private _ownerUid = _asset getVariable ["BIS_WL_ownerAsset", "123"];
if (getPlayerUID player != _ownerUid) exitWith {};

if (_newAccess == -1) then {
    if (_accessControl == 2) then {
        _newAccess = 3;
    } else {
        _newAccess = 2;
    };
};
if (_newAccess != 2 && _newAccess != 3) exitWith {};
if (_newAccess == _accessControl) exitWith {};

_asset setVariable ["WL2_accessControl", _newAccess, true];
if (_playSound) then {
    playSound3D ["a3\sounds_f\sfx\objects\upload_terminal\terminal_lock_close.wss", _asset, false, getPosASL _asset, 1, 1, 0, 0];
};