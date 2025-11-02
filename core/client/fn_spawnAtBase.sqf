#include "includes.inc"
params ["_firstSpawn"];

private _side = side group player;
private _homeBase = [_side] call WL2_fnc_getSideBase;

if (_firstSpawn) exitWith {
    player setVehiclePosition [_homeBase modelToWorld [0, 0, 0], [], 5, "NONE"];
};

private _spawnPosition = selectRandom ([_homeBase] call WL2_fnc_findSpawnsInSector);
private _enemySector = WL_TARGET_ENEMY;
private _isBaseVulnerable = _enemySector == _homeBase;
if (_isBaseVulnerable) then {
    private _neighbors = _homeBase getVariable ["WL2_connectedSectors", []];
    _neighbors = _neighbors select {
        _x getVariable ["BIS_WL_owner", independent] == _side
    };
    if (count _neighbors > 0) then {
        private _fallbackSector = selectRandom _neighbors;
        private _fallbackSpawns = [_fallbackSector] call WL2_fnc_findSpawnsInSector;
        player setVehiclePosition [selectRandom _fallbackSpawns, [], 5, "NONE"];
        player setDir (random 360);
    } else {
        _spawnPosition set [2, 300];
        player setPosASL _spawnPosition;
        player setDir (random 360);
        [player] spawn WL2_fnc_parachuteSetup;
    };
} else {
    player setVehiclePosition [_spawnPosition, [], 0, "NONE"];
};