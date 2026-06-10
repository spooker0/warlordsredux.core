#include "includes.inc"

private _isBeingConscripted = missionNamespace getVariable ["WL2_isBeingConscripted", false];
if (_isBeingConscripted) exitWith {
    missionNamespace setVariable ["WL2_isBeingConscripted", false];
};

private _spawnTarget = missionNamespace getVariable ["SQD_selectedSpawnTarget", objNull];
if (alive _spawnTarget) exitWith {
    [_spawnTarget] spawn WL2_fnc_executeFastTravelVehicle;
};

private _specialSpawnTarget = missionNamespace getVariable ["SQD_selectedSpecialSpawnTarget", [objNull, ""]];
_specialSpawnTarget params ["_target", "_spawnType"];

switch (_spawnType) do {
    case "airAssault": {
        private _canAirAssault = ([_target, "airAssault"] call WL2_fnc_mapButtonConditions) == "ok";
        if (_canAirAssault) then {
            [2, _target] call WL2_fnc_executeFastTravel;
        };
    };
    case "seized": {
        private _canTravelSeized = ([_target, "fastTravelSeized"] call WL2_fnc_mapButtonConditions) == "ok";
        if (_canTravelSeized) then {
            [0, _target] spawn WL2_fnc_executeFastTravel;
        };
    };
    case "stronghold": {
        private _canTravelStronghold = ([_target, "fastTravelStrongholdTarget"] call WL2_fnc_mapButtonConditions) == "ok";
        if (_canTravelStronghold) then {
            [5, _target] spawn WL2_fnc_executeFastTravel;
        };
    };
    case "fob": {
        private _canTravelFOB = ([_target, "fastTravelFOB"] call WL2_fnc_mapButtonConditions) == "ok";
        if (_canTravelFOB) then {
            private _forwardBaseArea = [getPosASL _target, WL_FOB_RANGE, WL_FOB_RANGE, 0, false];
            [6, _forwardBaseArea] spawn WL2_fnc_executeFastTravel;
        };
    };
    case "home": {
        [false] call WL2_fnc_spawnAtBase;
    };
    case "squadmate": {
        private _canTravelSquadmate = ([_target, "fastTravelSquad"] call WL2_fnc_mapButtonConditions) == "ok";
        if (_canTravelSquadmate) then {
            [_target] spawn WL2_fnc_executeFastTravelVehicle;
        };
    };
    default {
        [false] call WL2_fnc_spawnAtBase;
    };
};