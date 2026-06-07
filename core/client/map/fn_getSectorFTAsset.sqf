#include "includes.inc"
params ["_sector", ["_showAll", false]];

if (isNull _sector) exitWith {
    if (_showAll) then {
        [];
    } else {
        objNull;
    };
};

private _mapData = missionNamespace getVariable ["WL2_mapData", createHashMap];
private _sideVehicles = _mapData getOrDefault ["sideVehicles", []];;
_sideVehicles = _sideVehicles select { alive _x } select {
    WL_UNIT(_x, "hasFastTravel", 0) > 0;
};

private _tent = player getVariable ["WL2_respawnBag", objNull];
if (alive _tent) then {
    _sideVehicles pushBack _tent;
};
_sideVehicles = _sideVehicles inAreaArray (_sector getVariable "objectAreaComplete");

private _sectorArea = _sector getVariable "objectAreaComplete";
private _allSquadmates = ["getSquadmates", [getPlayerID player, false]] call SQD_fnc_query;
_allSquadmates = (_allSquadmates inAreaArray _sectorArea) select { WL_ISUP(_x) } select { _x != player };
_sideVehicles insert [-1, _allSquadmates, true];

private _sectorStronghold = _sector getVariable ["WL_stronghold", objNull];
if (isNull _sectorStronghold) then {
    _sideVehicles = [_sideVehicles, [], { _x distance _sector }, "ASCEND"] call BIS_fnc_sortBy;
} else {
    _sideVehicles = [_sideVehicles, [], { _x distance _sectorStronghold }, "ASCEND"] call BIS_fnc_sortBy;
};

if (_showAll) exitWith { _sideVehicles };

if (count _sideVehicles > 0) then {
    _sideVehicles # 0;
} else {
    objNull;
};