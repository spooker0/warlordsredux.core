#include "includes.inc"
params ["_sector", "_area", ["_showAll", false]];

if (isNull _sector) exitWith {
    if (_showAll) then {
        [];
    } else {
        objNull;
    };
};

if (count _area == 0) then {
    _area = _sector getVariable "objectAreaComplete";
};

private _sideVehicles = switch (BIS_WL_playerSide) do {
    case west: { BIS_WL_westOwnedVehicles };
    case east: { BIS_WL_eastOwnedVehicles };
    case independent: { BIS_WL_guerOwnedVehicles };
    default { [] };
};
_sideVehicles = _sideVehicles select { alive _x } select {
    WL_UNIT(_x, "hasFastTravel", 0) > 0;
} select {
    !(_x isKindOf "Man");
};

private _tent = player getVariable ["WL2_respawnBag", objNull];
if (alive _tent) then {
    _sideVehicles pushBack _tent;
};
_sideVehicles = _sideVehicles inAreaArray _area;

private _allSquadmates = ["getSquadmates", [getPlayerID player, false]] call SQD_fnc_query;
_allSquadmates = (_allSquadmates inAreaArray _area) select { WL_ISUP(_x) } select { _x != player };
_sideVehicles insert [-1, _allSquadmates, true];

private _sectorStronghold = _sector getVariable ["WL_stronghold", objNull];
if (isNull _sectorStronghold) then {
    _sideVehicles = [_sideVehicles, [], { random 1 }, "ASCEND"] call BIS_fnc_sortBy;
} else {
    _sideVehicles = [_sideVehicles, [], { _x distance _sectorStronghold }, "ASCEND"] call BIS_fnc_sortBy;
};

if (_showAll) exitWith { _sideVehicles };

if (count _sideVehicles > 0) then {
    _sideVehicles # 0;
} else {
    objNull;
};