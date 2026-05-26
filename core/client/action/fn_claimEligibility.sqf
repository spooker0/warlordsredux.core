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
!_isDemolishable