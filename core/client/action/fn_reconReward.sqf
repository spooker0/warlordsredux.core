#include "includes.inc"
params ["_reconnedObjects"];

private _newTargets = _reconnedObjects select {
    private _lastReconTime = _x getVariable ["WL_scannedByPlayer", -300];
    alive _x && lifeState _x != "INCAPACITATED" && _lastReconTime < serverTime - 300
};
private _targetPoints = 0;
{
    private _targetScore = if (_x isKindOf "Man") then {
        20;
    } else {
        100;
    };
    private _side = [_x] call WL2_fnc_getAssetSide;
    if (_side == BIS_WL_enemySide) then {
        _targetScore = _targetScore * 1.5;
    };
    _targetPoints = _targetPoints + _targetScore;
} forEach _newTargets;

private _enemiesSpotted = _targetPoints > 0;
if (_enemiesSpotted) then {
    [player, "spot", _targetPoints] remoteExec ["WL2_fnc_handleClientRequest", 2];
};

{
    _x setVariable ["WL_scannedByPlayer", serverTime];
} forEach _newTargets;

_enemiesSpotted;