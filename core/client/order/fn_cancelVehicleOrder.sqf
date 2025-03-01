params ["_originalPosition", "_limitDistance", "_ignoreSector"];

if (vehicle player != player) exitWith {
    true
};
if (!alive player || lifeState player == "INCAPACITATED") exitWith {
    true
};
if ((_originalPosition distance2D player) > _limitDistance) exitWith {
    true
};

private _sectors = (BIS_WL_sectorsArray # 0) select {
    player inArea (_x getVariable "objectAreaComplete")
};
if (count _sectors == 0 && !_ignoreSector) exitWith {
    true
};
private _sector = _sectors # 0;

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
    true
};

private _sectorStronghold = _sector getVariable ["WL_strongholdMarker", ""];
private _isInvalidPosition = if (player inArea _sectorStronghold) then {
    false;
} else {
    private _isInCarrierSector = count (_sector getVariable ["WL_aircraftCarrier", []]) > 0;
    if (_isInCarrierSector) then {
        ((getPosASL player) select 2) < 5
    } else {
        ((getPosATL player) select 2) > 1
    };
};
if (_isInvalidPosition) exitWith {
    true
};

false;