#include "includes.inc"
params ["_asset"];

private _datalinkTargets = listRemoteTargets BIS_WL_playerSide;

private _samRange = _asset getVariable ["DIS_advancedSamRange", 48000];

private _filteredTargets = _datalinkTargets select {
    private _target = _x # 0;
    private _targetTime = _x # 1;
    private _targetSide = [_target] call WL2_fnc_getAssetSide;
    private _targetAltitude = (ASLtoAGL (getPosASL _target)) # 2;
    private _targetDistance = _target distance _asset;
    _targetTime >= -10 && _targetSide != BIS_WL_playerSide && alive _target && _target isKindOf "Air" && _targetDistance < _samRange && _targetAltitude >= 50
};

_filteredTargets apply {
    [_x # 0, [_x # 0] call WL2_fnc_getAssetTypeName]
};