#include "includes.inc"
params ["_class"];

private _spawnClass = WL_ASSET(_class, "spawn", _class);

if (getNumber (configFile >> "CfgVehicles" >> _spawnClass >> "isUav") == 1) then {
    private _ownedVehiclesVar = format ["BIS_WL_ownedVehicles_%1", getPlayerUID player];
    private _ownedVehicles = missionNamespace getVariable [_ownedVehiclesVar, []];

    private _ownedUavs = _ownedVehicles select {
        private _isUav = unitIsUAV _x || getNumber (configFile >> "CfgVehicles" >> typeOf _x >> "isUav") == 1;
        _isUav && alive _x
    } select {
        WL_UNIT(_x, "decoy", 0) == 0
    };

    if (count _ownedUavs >= WL_MAX_AUTOASSETS) then {
        [false, format [localize "STR_A3_WL_tip_max_autonomous", WL_MAX_AUTOASSETS]];
    } else {
        [true, ""];
    };
} else {
    [true, ""];
};