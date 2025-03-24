if (vehicle player != player) exitWith { false };
if (isNull cursorObject) exitWith { false };

private _demolishTarget = cursorObject;
if !(_demolishTarget getVariable ["WL2_canDemolish", false]) exitWith { false };
if (player distance2D _demolishTarget > 10) exitWith { false };

private _strongholdSector = _demolishTarget getVariable ["WL_strongholdSector", objNull];
if (isNull _strongholdSector) exitWith { true }; // Not a stronghold
private _sectorOwner = _strongholdSector getVariable ["BIS_WL_owner", independent];
if (_sectorOwner == BIS_WL_playerSide) exitWith { false };

private _strongholdMarker = _strongholdSector getVariable ["WL_strongholdMarker", ""];
private _nearbyEnemies = _strongholdMarker nearEntities [["Man"], false, true, false];
_nearbyEnemies = _nearbyEnemies select {
    lifeState _x != "INCAPACITATED" &&
    side group _x != side group player
};

count _nearbyEnemies == 0;