#include "includes.inc"
params ["_target"];
private _rallyPointLocation = _target modelToWorld [0, 0, 0];
deleteVehicle _target;

private _previousRallyPoint = player getVariable ["WL2_rallyPoint", objNull];
if (!isNull _previousRallyPoint) then {
    player setVariable ["WL2_rallyPoint", objNull];
    deleteVehicle _previousRallyPoint;
};

private _rallyPointClass = if (BIS_WL_playerSide == west) then {
    "Land_MedicalTent_01_NATO_generic_open_F"
} else {
    "Land_MedicalTent_01_CSAT_brownhex_generic_open_F"
};

private _rallyTent = createVehicle [_rallyPointClass, _rallyPointLocation, [], 0, "NONE"];
_rallyTent setVehiclePosition [_rallyPointLocation, [], 0, "CAN_COLLIDE"];
_rallyTent setDir (getDir player);

[_rallyTent, player] remoteExec ["WL2_fnc_setupSimpleAsset", 0, true];

private _allRallyPoints = missionNamespace getVariable ["WL2_rallyPoints", []];
_allRallyPoints pushBack _rallyTent;
missionNamespace setVariable ["WL2_rallyPoints", _allRallyPoints, true];

player setVariable ["WL2_rallyPoint", _rallyTent];

private _ownedVehicleVar = format ["BIS_WL_ownedVehicles_%1", getPlayerUID player];
private _ownedVehicles = missionNamespace getVariable [_ownedVehicleVar, []];
_ownedVehicles pushBack _rallyTent;
missionNamespace setVariable [_ownedVehicleVar, _ownedVehicles, true];

["Rally point constructed successfully."] call WL2_fnc_smoothText;