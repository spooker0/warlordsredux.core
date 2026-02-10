#include "includes.inc"
params ["_target", "_caller"];

if (!alive _target) exitWith { false };

private _crew = (crew _target) select { alive _x };
if (count _crew > 0) exitWith { false };

private _isOwner = getPlayerUID _caller == (_target getVariable ["BIS_WL_ownerAsset", "123"]);
if (_isOwner) exitWith { false };

private _callerSide = side group _caller;
if (_callerSide == _target getVariable ["BIS_WL_ownerAssetSide", sideUnknown]) exitWith { false };

if (unitIsUAV _target) exitWith { false };

private _assetActualType = WL_ASSET_TYPE(_target);

private _isObstacle = WL_ASSET(_assetActualType, "obstacle", 0) > 0;
if (_isObstacle) exitWith { false };

private _isDemolishable = WL_ASSET(_assetActualType, "demolishable", 0) > 0;
if (!_isDemolishable) exitWith { true };

private _currentSector = BIS_WL_allSectors select {
    _target inArea (_x getVariable "objectAreaComplete")
} select {
    _x getVariable ["BIS_WL_owner", sideUnknown] == _callerSide
};
if (count _currentSector > 0) exitWith { true };

private _potentialBases = missionNamespace getVariable ["WL2_forwardBases", []];
private _forwardBases = _potentialBases select {
    _target distance2D _x < WL_FOB_RANGE
} select {
    _x getVariable ["WL2_forwardBaseOwner", sideUnknown] == _callerSide
};
count _forwardBases > 0;