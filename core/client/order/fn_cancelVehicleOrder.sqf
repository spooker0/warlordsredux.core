#include "..\..\warlords_constants.inc"

params ["_originalPosition", "_limitDistance", "_ignoreSector", "_asset"];

if (vehicle player != player) exitWith {
    [true, "Player is in vehicle."];
};
if (!alive player || lifeState player == "INCAPACITATED") exitWith {
    [true, "Player is dead."];
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

private _enemiesNearPlayer = (allPlayers inAreaArray [player, 100, 100]) select {
    _x != player &&
    BIS_WL_playerSide != side group _x &&
    alive _x &&
    lifeState _x != "INCAPACITATED"
};
private _homeBase = BIS_WL_playerSide call WL2_fnc_getSideBase;
private _isInHomeBase = _sector == _homeBase;
private _nearbyEnemies = if (_isInHomeBase || _ignoreSector) then {
    false
} else {
    count _enemiesNearPlayer > 0
};
if (_nearbyEnemies) exitWith {
    [true, "Enemies are nearby."];
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

private _sectorStronghold = _sector getVariable ["WL_strongholdMarker", ""];
if (_asset inArea _sectorStronghold) exitWith {
    [false, ""];
};

private _isInCarrierSector = _sector getVariable ["WL2_isAircraftCarrier", false];
if (_isInCarrierSector && ((getPosASL _asset) # 2) < 5) exitWith {
    [true, "Asset cannot be deployed so close to water."];
};

if (_isInCarrierSector) exitWith {
    [false, ""];
};

if (((getPosATL _asset) # 2) > 1) exitWith {
    [true, "Asset cannot be deployed too far above ground."];
};

if (surfaceIsWater (getPosATL _asset)) exitWith {
    [true, "Asset cannot be deployed on water."];
};

[false, ""]