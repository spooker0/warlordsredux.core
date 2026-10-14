#include "includes.inc"

private _allCatapultRails = allMissionObjects "Land_CraneRail_01_F";
{
    _x setVariable ["BIS_WL_ownerAssetSide", independent, true];
} forEach _allCatapultRails;

private _serverOwnedVehicles = missionNamespace getVariable ["BIS_WL_ownedVehicles_server", []];
_allCatapultRails append _serverOwnedVehicles;
missionNamespace setVariable ["BIS_WL_ownedVehicles_server", _allCatapultRails];

uiSleep 5;

private _vehicleVariables = createHashMapFromArray [
    [west, "BIS_WL_westOwnedVehicles"],
    [east, "BIS_WL_eastOwnedVehicles"],
    [independent, "BIS_WL_guerOwnedVehicles"]
];
private _previousOwnedVehicles = createHashMap;

while { !BIS_WL_missionEnd } do {
    private _ownedVehiclesBySide = createHashMapFromArray [
        [west, createHashMap],
        [east, createHashMap],
        [independent, createHashMap]
    ];
    {
        private _playerSide = side group _x;
        if !(_playerSide in _ownedVehiclesBySide) then {
            continue;
        };

        private _playerUID = getPlayerUID _x;
        private _playerVehicleVariable = format ["BIS_WL_ownedVehicles_%1", _playerUID];
        private _vehicles = missionNamespace getVariable [_playerVehicleVariable, []];
        private _sideVehicles = _ownedVehiclesBySide getOrDefault [_playerSide, createHashMap];
        {
            if (!alive _x) then {
                continue;
            };

            private _vehicleOwner = _x getVariable ["BIS_WL_ownerAsset", "123"];
            if (_vehicleOwner == _playerUID || _vehicleOwner == "123") then {
                _sideVehicles set [hashValue _x, _x];
            };
        } forEach _vehicles;
    } forEach (call BIS_fnc_listPlayers);

#if WL_ZEUS_ENABLED
    private _zeusVehicles = missionNamespace getVariable ["BIS_WL_ownedVehicles_zeus", []];
    {
        private _vehicleSide = side group _x;
        if (_vehicleSide in _ownedVehiclesBySide) then {
            private _sideVehicles = _ownedVehiclesBySide getOrDefault [_vehicleSide, createHashMap];
            _sideVehicles set [hashValue _x, _x];
        };
    } forEach _zeusVehicles;
#endif

    private _serverVehicles = missionNamespace getVariable ["BIS_WL_ownedVehicles_server", []];
    _serverVehicles = _serverVehicles select {
        alive _x
    } select {
        [_x] call WL2_fnc_getAssetSide == independent
    };

    missionNamespace setVariable ["BIS_WL_ownedVehicles_server", _serverVehicles];
    private _guerOwnedVehicles = _ownedVehiclesBySide getOrDefault [independent, createHashMap];
    {
        _guerOwnedVehicles set [hashValue _x, _x];
    } forEach _serverVehicles;

    {
        private _previousSideVehicles = _previousOwnedVehicles getOrDefault [_x, []];
        if (_previousSideVehicles isNotEqualTo _y) then {
            private _sideVehiclesVar = _vehicleVariables getOrDefault [_x, ""];
            if (_sideVehiclesVar != "") then {
                missionNamespace setVariable [_sideVehiclesVar, values _y, true];
            };
        };
    } forEach _ownedVehiclesBySide;
    _previousOwnedVehicles = _ownedVehiclesBySide;

    {
        private _side = _x;
        private _currentSideTargetVar = format ["BIS_WL_currentTarget_%1", _side];
        private _currentSideTarget = missionNamespace getVariable [_currentSideTargetVar, objNull];
        private _currentSideTargetOwner = _currentSideTarget getVariable ["BIS_WL_owner", sideUnknown];
        if (_currentSideTargetOwner == _side) then {
            missionNamespace setVariable [_currentSideTargetVar, objNull, true];
            [_currentSideTarget, _currentSideTargetOwner] remoteExec ["WL2_fnc_sectorMarkerUpdate", 0];
        };
    } forEach BIS_WL_competingSides;

    uiSleep 1;
};