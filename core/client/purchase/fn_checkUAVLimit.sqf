#include "includes.inc"
params ["_class"];

private _spawnClass = WL_ASSET(_class, "spawn", _class);

if (getNumber (configFile >> "CfgVehicles" >> _spawnClass >> "isUav") == 1) then {
    private _ownedVehiclesVar = format ["BIS_WL_ownedVehicles_%1", getPlayerUID player];
    private _ownedVehicles = missionNamespace getVariable [_ownedVehiclesVar, []];

    private _ownedUavs = _ownedVehicles select {
        private _isUav = unitIsUAV _x || getNumber (configFile >> "CfgVehicles" >> typeOf _x >> "isUav") == 1;
        _isUav && alive _x
    };

    private _uavLimit = WL_MAX_AUTOASSETS;
    if (count _ownedUavs >= _uavLimit) then {
        [false, format [localize "STR_A3_WL_tip_max_autonomous", _uavLimit]];
    } else {
        [true, ""];
    };
} else {
    [true, ""];
};