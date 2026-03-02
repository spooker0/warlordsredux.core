#include "includes.inc"
params ["_position", "_munitionCount"];

private _craterTypes = [
    "Land_ShellCrater_02_large_F",
    "Land_ShellCrater_02_small_F",
    "SpaceshipCapsule_01_debris_F",
    "CraterLong",
    "CraterLong_02_F"
];

for "_i" from 1 to _munitionCount do {
    private _craterType = selectRandom _craterTypes;

    private _angle = random 360;
    private _distance = random 25;
    private _craterPos = if (_munitionCount > 1) then {
        _position getPos [_distance, _angle];
    } else {
        _position
    };

    private _inCarrierSector = {
        _craterPos inArea (_x getVariable "objectAreaComplete") && _x getVariable ["WL2_isAircraftCarrier", false];
    } count BIS_WL_allSectors > 0;
    if (_inCarrierSector) then {
        _craterPos set [2, 24];
        [player, "orderAsset", "vehicle", _craterPos, _craterType, random 360, true, true] remoteExec ["WL2_fnc_handleClientRequest", 2];
    } else {
        [player, "orderAsset", "vehicle", _craterPos, _craterType, random 360, false, true] remoteExec ["WL2_fnc_handleClientRequest", 2];
    };
};