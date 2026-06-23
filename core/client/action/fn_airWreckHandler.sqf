#include "includes.inc"
params ["_asset"];
removeFromRemainsCollector [_asset];

while { alive _asset } do {
    uiSleep 1;
};

private _assetSide = [_asset] call WL2_fnc_getAssetSide;

private _wrecksNearby = allDead select {
    _x getVariable ["WL2_timeOfDeath", 0] > 0
} select {
    _x distance2D _asset < 500
} select {
    [_x] call WL2_fnc_getAssetSide == _assetSide
};

private _assetValue = round (WL_UNIT(_asset, "cost", 0) / 300) * 100;
if (count _wrecksNearby > 0) then {
    private _sortedWrecksNearby = [_wrecksNearby, [_asset], { _input0 distance _x }, "ASCEND"] call BIS_fnc_sortBy;
    private _closestWreck = _sortedWrecksNearby # 0;

    private _closestWreckValue = _closestWreck getVariable ["WL2_wreckValue", 0];
    if (_closestWreckValue > _assetValue) then {
        _closestWreck setVariable ["WL2_wreckValue", _closestWreckValue + _assetValue, true];
        _closestWreck setVariable ["WL2_timeOfDeath", serverTime, true];
        deleteVehicle _asset;
    } else {
        _asset setVariable ["WL2_wreckValue", _closestWreckValue + _assetValue, true];
        _asset setVariable ["WL2_timeOfDeath", serverTime, true];
        deleteVehicle _closestWreck;
    };
} else {
    _asset setVariable ["WL2_wreckValue", _assetValue, true];
    _asset setVariable ["WL2_timeOfDeath", serverTime, true];
};