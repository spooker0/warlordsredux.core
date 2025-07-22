#include "includes.inc"
if (cameraOn != player) exitWith { false };
if (isNull cursorObject) exitWith { false };

private _demolishTarget = cursorObject;
if !(_demolishTarget getVariable ["WL2_canDemolish", false]) exitWith { false };

private _strongholdSector = _demolishTarget getVariable ["WL_strongholdSector", objNull];
if (isNull _strongholdSector) exitWith {
    player distance2D _demolishTarget < 10;
};
private _sectorOwner = _strongholdSector getVariable ["BIS_WL_owner", independent];
// if (_sectorOwner == BIS_WL_playerSide) exitWith { false };

private _strongholdRadius = _demolishTarget getVariable ["WL_strongholdRadius", 0];
if (player distance2D _demolishTarget > _strongholdRadius) exitWith {
    player distance2D _demolishTarget < 10;
};
private _strongholdArea = [
    getPosASL _demolishTarget,
    _strongholdRadius,
    _strongholdRadius,
    0,
    false
];
private _nearbyEnemies = _strongholdArea nearEntities [["Man"], false, true, false];
_nearbyEnemies = _nearbyEnemies select {
    lifeState _x != "INCAPACITATED" &&
    side group _x != side group player
};

count _nearbyEnemies == 0;