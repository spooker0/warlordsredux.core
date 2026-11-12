#include "includes.inc"
params ["_originalPosition", "_limitDistance", "_ignoreSector", "_asset"];

if (vehicle player != player) exitWith {
    [true, localize "STR_WL_playerInVehicle"];
};
if (WL_ISDOWN(player)) exitWith {
    [true, localize "STR_WL_playerIsDown"];
};
if ((_originalPosition distance2D _asset) > _limitDistance) exitWith {
    [true, localize "STR_WL_assetMovedTooFar"];
};

private _side = BIS_WL_playerSide;

private _teamSectorsData = WL_SECTORS_DATA(_side);
private _ownedSectors = _teamSectorsData getOrDefault ["owned", []];
private _sectors = _ownedSectors select {
    _asset inArea (_x getVariable "objectAreaComplete")
};
private _potentialBases = missionNamespace getVariable ["WL2_forwardBases", []];
private _forwardBases = _potentialBases select {
    _asset distance2D _x < WL_FOB_RANGE &&
    _x getVariable ["WL2_forwardBaseOwner", sideUnknown] == _side
};
private _inRange = count _forwardBases > 0 || count _sectors > 0;

if (!_inRange && !_ignoreSector) exitWith {
    [true, localize "STR_WL_assetMustBeInSectorOrFob"];
};

private _sector = if (count _sectors > 0) then {
    _sectors # 0;
} else {
    if (count _forwardBases > 0) then {
        _forwardBases # 0;
    } else {
        objNull;
    };
};

private _enemiesNearPlayer = (allPlayers inAreaArray [player, WL_ENEMIES_NEAR_RADIUS, WL_ENEMIES_NEAR_RADIUS]) select {
    _x isKindOf "Man"
} select {
    BIS_WL_playerSide != side group _x
} select {
    _x != player
} select {
    WL_ISUP(_x)
} select {
    isTouchingGround _x
} select {
    private _position = getPosASL _x;
    !(surfaceIsWater _position) || (_position # 2 > 20 && _position # 2 < 30)
};

private _homeBase = _teamSectorsData getOrDefault ["base", objNull];
private _isInHomeBase = _sector == _homeBase;
private _nearbyEnemies = if (_isInHomeBase || _ignoreSector) then {
    false
} else {
    count _enemiesNearPlayer > 0
};
if (_nearbyEnemies) exitWith {
    [true, localize "STR_WL_enemiesNearby"];
};

// any sector regardless
_sectors = BIS_WL_allSectors select {
    _asset inArea (_x getVariable "objectAreaComplete")
};
_sector = if (count _sectors > 0) then {
    _sectors # 0;
} else {
    objNull;
};

if (count _forwardBases > 0) exitWith {
    [false, ""];
};

private _sectorStronghold = _sector getVariable ["WL_stronghold", objNull];
private _strongholdRadius = _sectorStronghold getVariable ["WL_strongholdRadius", 0];
if (_asset distance2D _sectorStronghold < _strongholdRadius) exitWith {
    [false, ""];
};

private _isInWaterSector = _sector getVariable ["WL2_isAircraftCarrier", false] || {
    {
        _asset inArea _x
    } count WL_DESTROYER_OUTLINES > 0
};
if (_isInWaterSector && ((getPosASL _asset) # 2) < 5) exitWith {
    [true, localize "STR_WL_assetTooCloseToWater"];
};

if (_isInWaterSector) exitWith {
    [false, ""];
};

if (surfaceIsWater (getPosATL _asset) && !(_asset isKindOf "Boat_F")) exitWith {
    [true, localize "STR_WL_assetOnWater"];
};

[false, ""]