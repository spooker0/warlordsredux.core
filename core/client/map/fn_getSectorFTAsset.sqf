#include "includes.inc"
params ["_sector", "_allowInfantry"];

private _mapData = missionNamespace getVariable ["WL2_mapData", createHashMap];
private _sideVehicles = _mapData getOrDefault ["sideVehicles", []];;
_sideVehicles = _sideVehicles inAreaArray (_sector getVariable "objectAreaComplete");
_sideVehicles = _sideVehicles select { alive _x } select {
    private _assetActualType = _x getVariable ["WL2_orderedClass", typeOf _x];
    WL_ASSET(_assetActualType, "hasFastTravel", 0) > 0;
};

if (_allowInfantry) then {
    private _isSquadLeader = ["isSquadLeader", [getPlayerID player]] call SQD_fnc_query;

    private _sectorArea = _sector getVariable "objectAreaComplete";
    if (_isSquadLeader) then {
        private _allSquadmates = _mapData getOrDefault ["allSquadmates", []];
        _allSquadmates = _allSquadmates inAreaArray _sectorArea;
        _sideVehicles insert [-1, _allSquadmates, true];
    } else {
        private _squadLeader = ["getSquadLeaderForPlayer", [getPlayerID player]] call SQD_fnc_query;
        _squadLeader = vehicle _squadLeader;

        if (_squadLeader inArea _sectorArea) then {
            _sideVehicles insert [-1, [_squadLeader], true];
        };
    };
    _sideVehicles = _sideVehicles select {
        WL_ISUP(_x) && _x != player
    };
};

private _sectorStronghold = _sector getVariable ["WL_stronghold", objNull];
if (isNull _sectorStronghold) then {
    _sideVehicles = [_sideVehicles, [], { _x distance _sector }, "ASCEND"] call BIS_fnc_sortBy;
} else {
    _sideVehicles = [_sideVehicles, [], { _x distance _sectorStronghold }, "ASCEND"] call BIS_fnc_sortBy;
};

if (count _sideVehicles > 0) then {
    _sideVehicles # 0;
} else {
    objNull;
};