#include "includes.inc"
params ["_sector"];

private _sectorMarker = _sector getVariable "objectAreaComplete";
private _carrier = ((8 allObjects 0) select {
    _x isKindOf "Land_Carrier_01_hull_base_F" && _x inArea _sectorMarker;
}) # 0;

private _assetData = WL_ASSET_DATA;
private _unitsPool = [];
{
    private _class = _x;
    private _data = _y;
    private _unitSpawn = _data getOrDefault ["unitSpawn", 0];
    if (_unitSpawn > 0) then {
        _unitsPool pushBack _class;
    };
} forEach _assetData;

private _infantryGroups = [];
private _infantryUnits = [];
private _spawnLocations = _sector getVariable ["WL2_aircraftCarrierInf", []];

for "_i" from 0 to 5 do {
    private _infantryGroup = createGroup independent;
    _infantryGroup deleteGroupWhenEmpty true;
    _infantryGroups pushBack _infantryGroup;

    private _spawnPosition = selectRandom _spawnLocations;

    for "_j" from 0 to 8 do {
        private _infantry = _infantryGroup createUnit [selectRandom _unitsPool, _spawnPosition, [], 0, "NONE"];
        _infantry setVehiclePosition [_spawnPosition, [], 10, "NONE"];

        private _spawnHeight = getPosASL _infantry # 2;
        if (_spawnHeight < 10) then {
            deleteVehicle _infantry;
        } else {
            _infantry call WL2_fnc_newAssetHandle;
            doStop _infantry;
            _infantry setUnitPos "MIDDLE";
            _infantry disableAI "PATH";
            _infantryUnits pushBack _infantry;
        };

        uiSleep 0.001;
    };

    _infantryGroup setBehaviour "COMBAT";
};

private _vehicleUnits = [];
private _presetVehicles = _sector getVariable ["WL2_vehiclesToSpawn", []];
{
    private _vehicleInfo = _x;
    _vehicleInfo params ["_type", "_pos", "_dir"];
    private _vehicleArray = [_pos, _dir, _type, independent] call BIS_fnc_spawnVehicle;
    _vehicleArray params ["_vehicle", "_crew", "_group"];

    _vehicle setPosASL _pos;

    _vehicleUnits pushBack _vehicle;

    {
        _x call WL2_fnc_newAssetHandle;
        _vehicleUnits pushBack _x;
    } forEach _crew;

    [_vehicle, driver _vehicle, typeof _vehicle] call WL2_fnc_processOrder;
    _vehicle allowCrewInImmobile [true, true];

    _vehicle setFuel 0;
} forEach _presetVehicles;

private _allUnits = _vehicleUnits + _infantryUnits;
_sector setVariable ["WL2_sectorDefenders", _allUnits];

private _ownedVehicles = missionNamespace getVariable ["BIS_WL_ownedVehicles_server", []];
_ownedVehicles append _allUnits;
missionNamespace setVariable ["BIS_WL_ownedVehicles_server", _ownedVehicles];