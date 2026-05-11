#include "includes.inc"
params ["_asset", "_radius", "_iteration"];

private _assetSide = [_asset] call WL2_fnc_getAssetSide;

private _assetPos = _asset modelToWorldVisual [0, 0, 0];
private _assetHeight = (_assetPos # 2) min (getPosASL _asset # 2);
if (waterDamaged _asset) exitWith {
    _asset setVariable ["WL_scannedObjects", []];
    _asset setVariable ["WL_scanRadius", 0];
};

_asset setVariable ["WL_scanRadius", _radius];

if (_assetSide != side group player) exitWith {};

private _enemyUnits = switch (_assetSide) do {
    case west: { BIS_WL_eastOwnedVehicles + BIS_WL_guerOwnedVehicles };
    case east: { BIS_WL_westOwnedVehicles + BIS_WL_guerOwnedVehicles };
    default { [] };
};
if (isNil "_enemyUnits") then {
    _enemyUnits = [];
};

private _relevantVehicles = _enemyUnits select {
    private _vehiclePos = _x modelToWorldVisual [0, 0, 0];
    (_x getVariable ["WL_spawnedAsset", false] || isPlayer _x)
};

private _vehiclesInRadius = _relevantVehicles select {
    private _vehiclePos = _x modelToWorldVisual [0, 0, 0];
    _vehiclePos distance2D _assetPos < _radius;
} select {
    alive _x;
} select {
    vehicle _x == _x;
};
private _scannedObjects = _vehiclesInRadius select {
    private _vehicleSide = [_x] call WL2_fnc_getAssetSide;
    _vehicleSide != _assetSide;
};

{
    _assetSide reportRemoteTarget [_x, 10];
} forEach _scannedObjects;

private _scanArea = [_assetPos, _radius, _radius, 0, false];
private _minesInRadius = allMines inAreaArray _scanArea;
{
    _assetSide revealMine _x;
} forEach _minesInRadius;

{
    if (_x getVariable ["WL_lastSpotted", objNull] != player) then {
        _x setVariable ["WL_lastSpotted", player, [2, clientOwner]];
    };
} forEach (_scannedObjects select {
    _x getVariable ["BIS_WL_ownerAsset", "123"] != "123"
});

if (cameraOn == _asset) then {
    if (_iteration % 2 == 0) then {
        playSoundUI ["radarTargetLost", 2, 1, true];
    };
    [_scannedObjects] call WL2_fnc_reconReward;
};

_asset setVariable ["WL_scannedObjects", _scannedObjects];