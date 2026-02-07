#include "includes.inc"
params ["_originalPosition", "_limitDistance", "_ignoreSector", "_asset", "_allowAboveGround"];

if (vehicle player != player) exitWith {
    [true, "Player is in vehicle."];
};
if (WL_ISDOWN(player)) exitWith {
    [true, "Player is down."];
};
if ((_originalPosition distance2D _asset) > _limitDistance) exitWith {
    [true, "Asset moved too far from original position."];
};

private _sectors = (BIS_WL_sectorsArray # 0) select {
    _asset inArea (_x getVariable "objectAreaComplete")
};
private _potentialBases = missionNamespace getVariable ["WL2_forwardBases", []];
private _forwardBases = _potentialBases select {
    _asset distance2D _x < WL_FOB_RANGE &&
    _x getVariable ["WL2_forwardBaseOwner", sideUnknown] == BIS_WL_playerSide
};
private _inRange = count _forwardBases > 0 || count _sectors > 0;

if (!_inRange && !_ignoreSector) exitWith {
    [true, "Asset must be within a sector or forward base."];
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

private _enemiesNearPlayer = (allUnits inAreaArray [player, 150, 150]) select {
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

private _homeBase = BIS_WL_playerSide call WL2_fnc_getSideBase;
private _isInHomeBase = _sector == _homeBase;
private _nearbyEnemies = if (_isInHomeBase || _ignoreSector) then {
    false
} else {
    count _enemiesNearPlayer > 0
};
if (_nearbyEnemies) exitWith {
    [true, "There are enemies nearby."];
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
    [true, "Asset cannot be deployed so close to water."];
};

if (_isInWaterSector) exitWith {
    [false, ""];
};

if (_allowAboveGround) exitWith {
    [false, ""];
};

if (((getPosATL _asset) # 2) > 1) exitWith {
    [true, "Asset cannot be deployed too far above ground."];
};

if (surfaceIsWater (getPosATL _asset)) exitWith {
    [true, "Asset cannot be deployed on water."];
};

[false, ""]