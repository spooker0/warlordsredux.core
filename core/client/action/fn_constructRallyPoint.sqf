#include "includes.inc"
params ["_target"];
private _rallyPointLocation = _target modelToWorld [0, 0, 0];
deleteVehicle _target;

private _previousRallyPoint = player getVariable ["WL2_rallyPoint", objNull];
if (!isNull _previousRallyPoint) then {
    player setVariable ["WL2_rallyPoint", objNull];
    if (_previousRallyPoint getVariable ["WL2_orderedClass", ""] == "Land_RallyBuilding") then {
        _previousRallyPoint setVariable ["WL2_orderedClass", typeof _previousRallyPoint, true];
        _previousRallyPoint setVariable ["WL_spawnedAsset", false, true];
        _previousRallyPoint setVariable ["BIS_WL_ownerAsset", "123", true];
        _previousRallyPoint setVariable ["BIS_WL_ownerAssetSide", sideUnknown, true];
        _previousRallyPoint setVariable ["WL2_canDemolish", false, true];
    } else {
        deleteVehicle _previousRallyPoint;
    };
};

private _buildings = if (surfaceIsWater _rallyPointLocation) then {
    [];
} else {
    [_rallyPointLocation] call WL2_fnc_findStrongholdBuilding;
};
_buildings = _buildings select {
    isNull (_x getVariable ["WL_strongholdSector", objNull]);
} select {
    alive _x && !(_x isKindOf "Ruins");
};
private _rallyPoint = if (count _buildings == 0) then {
    private _rallyPointClass = if (BIS_WL_playerSide == west) then {
        "Land_MedicalTent_01_NATO_generic_open_F"
    } else {
        "Land_MedicalTent_01_CSAT_brownhex_generic_open_F"
    };

    private _rallyTent = createVehicle [_rallyPointClass, _rallyPointLocation, [], 0, "NONE"];
    _rallyTent setVehiclePosition [_rallyPointLocation, [], 0, "CAN_COLLIDE"];
    _rallyTent setDir (getDir player);

    [_rallyTent, player] remoteExec ["WL2_fnc_setupSimpleAsset", 0, true];
    _rallyTent;
} else {
    private _rallyBuilding = _buildings # 0;
    [_rallyBuilding, player] remoteExec ["WL2_fnc_setupSimpleAsset", 0, true];
    _rallyBuilding setVariable ["WL2_orderedClass", "Land_RallyBuilding", true];
    _rallyBuilding;
};

private _allRallyPoints = missionNamespace getVariable ["WL2_rallyPoints", []];
_allRallyPoints pushBack _rallyPoint;
missionNamespace setVariable ["WL2_rallyPoints", _allRallyPoints, true];

player setVariable ["WL2_rallyPoint", _rallyPoint];

private _ownedVehicleVar = format ["BIS_WL_ownedVehicles_%1", getPlayerUID player];
private _ownedVehicles = missionNamespace getVariable [_ownedVehicleVar, []];
_ownedVehicles pushBack _rallyPoint;
missionNamespace setVariable [_ownedVehicleVar, _ownedVehicles, true];

["Rally point constructed successfully."] call WL2_fnc_smoothText;