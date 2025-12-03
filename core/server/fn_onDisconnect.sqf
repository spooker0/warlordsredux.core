#include "includes.inc"
params ["_uid", ["_instant", false]];

private _ownedAI = allUnits select { _x getVariable ["BIS_WL_ownerAsset", "123"] == _uid };
{
    if (!isPlayer _x) then {
        deleteVehicle _x;
    };
} forEach _ownedAI;

if (!_instant) then {
    uiSleep 120;
};

private _playerUnit = _uid call BIS_fnc_getUnitByUid;
if (!isNull _playerUnit && !_instant) exitWith {};

// Remove owned vehicles
private _ownedVehiclesVar = format ["BIS_WL_ownedVehicles_%1", _uid];
private _ownedVehicles = missionNamespace getVariable [_ownedVehiclesVar, []];
_ownedVehicles = _ownedVehicles select { alive _x };
{
    if (unitIsUAV _x) then {
        private _group = group effectiveCommander _x;
        {
            _x deleteVehicleCrew _x;
        } forEach crew _x;
        deleteGroup _group;
    };

    deleteVehicle _x;
} forEach _ownedVehicles;
missionNamespace setVariable [_ownedVehiclesVar, []];

// Remove owned mines
private _ownedMineVar = format ["WL2_ownedMines_%1", _uid];
private _ownedMines = missionNamespace getVariable [_ownedMineVar, []];
{
    if (alive _x) then {
        deleteVehicle _x;
    };
} forEach _ownedMines;
missionNamespace setVariable [_ownedMineVar, [], true];