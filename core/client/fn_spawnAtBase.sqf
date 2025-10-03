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
    _spawnPosition set [2, 300];
    player setPosASL _spawnPosition;
    player setDir (random 360);
    player setVelocityModelSpace [0, 30, 0];
    [player] spawn WL2_fnc_parachuteSetup;
} else {
    player setVehiclePosition [_spawnPosition, [], 0, "NONE"];
};