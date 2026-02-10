#include "includes.inc"
params ["_projectile"];
private _startPos = _projectile modelToWorldWorld [0, 0, 0];
private _projectileVelocity = velocity _projectile;
private _terrainIntersect = terrainIntersectAtASL [
    _startPos,
    _startPos vectorAdd (_projectileVelocity vectorMultiply 20)
];

private _coordinates = [_terrainIntersect # 0, _terrainIntersect # 1, 0];
private _enemiesNear = (_coordinates nearEntities 500) select {
    ([_x] call WL2_fnc_getAssetSide) != BIS_WL_playerSide &&
    WL_ISUP(_x)
};

private _assetData = WL_ASSET_DATA;
private _filteredEnemies = _enemiesNear select {
    private _assetActualType = WL_ASSET_TYPE(_x);
    WL_ASSET_FIELD(_assetData, _assetActualType, "cost", 0) > 0;
};

if (count _filteredEnemies == 0) exitWith {};

private _sortedEnemies = [_filteredEnemies, [_coordinates], {
    private _coordinates = _input0;
    _x distance2D _coordinates;
}, "ASCEND"] call BIS_fnc_sortBy;

private _closestEnemy = _sortedEnemies # 0;
private _closestEnemyName = if (_closestEnemy isKindOf "Man") then {
    "Infantry";
} else {
    [_closestEnemy] call WL2_fnc_getAssetTypeName;
};
[format ["Terminal projectile target: %1", _closestEnemyName]] call WL2_fnc_smoothText;

private _terminalSpeed = velocityModelSpace _projectile # 1;
while { alive _projectile } do {
    private _targetVectorDirAndUp = [getPosASL _projectile, getPosASL _closestEnemy] call BIS_fnc_findLookAt;
    _projectile setVectorDirAndUp _targetVectorDirAndUp;
    _projectile setVelocityModelSpace [0, _terminalSpeed, 0];

    uiSleep 0.001;
};