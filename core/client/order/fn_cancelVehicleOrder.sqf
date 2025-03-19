params ["_originalPosition", "_limitDistance", "_ignoreSector", "_asset"];

if (vehicle player != player) exitWith {
    [true, "player is in vehicle"]
};
if (!alive player || lifeState player == "INCAPACITATED") exitWith {
    [true, "player is dead"]
};
if ((_originalPosition distance2D _asset) > _limitDistance) exitWith {
    [true, "distance to target is too far"]
};

private _sectors = (BIS_WL_sectorsArray # 0) select {
    _asset inArea (_x getVariable "objectAreaComplete")
};
private _potentialBases = missionNamespace getVariable ["WL2_forwardBases", []];
private _forwardBases = _potentialBases select {
    _asset distance2D _x < 100 &&
    _x getVariable ["WL2_forwardBaseOwner", sideUnknown] == BIS_WL_playerSide
};
private _inRange = count _forwardBases > 0 || count _sectors > 0;

if (!_inRange && !_ignoreSector) exitWith {
    [true, "target is not in a sector"]
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
    [true, "enemies are nearby"]
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

private _sectorStronghold = _sector getVariable ["WL_strongholdMarker", ""];
private _isInvalidPosition = if (_asset inArea _sectorStronghold) then {
    false;
} else {
    private _isInCarrierSector = count (_sector getVariable ["WL_aircraftCarrier", []]) > 0;
    if (_isInCarrierSector) then {
        ((getPosASL _asset) # 2) < 5
    } else {
        ((getPosATL _asset) # 2) > 1 || surfaceIsWater (getPosATL _asset)
    };
};
if (_isInvalidPosition) exitWith {
    [true, "target is in an invalid position"]
};

[false, ""]