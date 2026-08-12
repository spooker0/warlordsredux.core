#include "includes.inc"
params ["_firstSpawn"];

private _side = BIS_WL_playerSide;
private _homeBase = [_side] call WL2_fnc_getSideBase;

private _settingsMap = missionProfileNamespace getVariable ["WL2_settings", createHashMap];
private _hideFrontlineMenu = _settingsMap getOrDefault ["hideFrontlineMenu", false];
if (!_hideFrontlineMenu) then  {
    [player] call WL2_fnc_frontlineAction;
};

private _baseFlag = _homeBase getVariable ["WL2_baseFlag", _homeBase];
private _homeBaseLocation = _baseFlag modelToWorld [0, -5, 0];
if (_firstSpawn) exitWith {
    player setVehiclePosition [_homeBaseLocation, [], 0, "NONE"];
};

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
        private _spawnPosition = selectRandom ([_homeBase] call WL2_fnc_findSpawnsInSector);
        _spawnPosition set [2, 300];
        player setPosASL _spawnPosition;
        player setDir (random 360);
        [player] spawn WL2_fnc_parachuteSetup;
    };
} else {
    player setVehiclePosition [_homeBaseLocation, [], 0, "NONE"];
};