#include "includes.inc"

private _allCatapultRails = allMissionObjects "Land_CraneRail_01_F";
{
    _x setVariable ["BIS_WL_ownerAssetSide", independent, true];
} forEach _allCatapultRails;

private _serverOwnedVehicles = missionNamespace getVariable ["BIS_WL_ownedVehicles_server", []];
_allCatapultRails append _serverOwnedVehicles;
missionNamespace setVariable ["BIS_WL_ownedVehicles_server", _allCatapultRails];

uiSleep 5;

while { !BIS_WL_missionEnd } do {
    private _westOwnedVehicles = [];
    private _eastOwnedVehicles = [];
    private _guerOwnedVehicles = [];
    {
        private _player = _x;
        private _playerVehicleVariable = format ["BIS_WL_ownedVehicles_%1", getPlayerUID _player];
        private _vehicles = missionNamespace getVariable [_playerVehicleVariable, []];
        _vehicles = _vehicles select { alive _x } select {
            private _vehicleOwner = _x getVariable ["BIS_WL_ownerAsset", "123"];
            _vehicleOwner == getPlayerUID _player || _vehicleOwner == "123";
        };
        switch (side group _player) do {
            case west: {
                _westOwnedVehicles append _vehicles;
            };
            case east: {
                _eastOwnedVehicles append _vehicles;
            };
            case independent: {
                _guerOwnedVehicles append _vehicles;
            };
        };
    } forEach (call BIS_fnc_listPlayers);

    private _serverVehicles = missionNamespace getVariable ["BIS_WL_ownedVehicles_server", []];
    _serverVehicles = _serverVehicles select { alive _x } select {
        [_x] call WL2_fnc_getAssetSide == independent;
    };
    _guerOwnedVehicles append _serverVehicles;

    private _originalWestOwnedVehicles = missionNamespace getVariable ["BIS_WL_westOwnedVehicles", [objNull]];
    private _originalEastOwnedVehicles = missionNamespace getVariable ["BIS_WL_eastOwnedVehicles", [objNull]];
    private _originalGuerOwnedVehicles = missionNamespace getVariable ["BIS_WL_guerOwnedVehicles", [objNull]];

    if (_originalWestOwnedVehicles isNotEqualTo _westOwnedVehicles) then {
        missionNamespace setVariable ["BIS_WL_westOwnedVehicles", _westOwnedVehicles, true];
    };
    if (_originalEastOwnedVehicles isNotEqualTo _eastOwnedVehicles) then {
        missionNamespace setVariable ["BIS_WL_eastOwnedVehicles", _eastOwnedVehicles, true];
    };
    if (_originalGuerOwnedVehicles isNotEqualTo _guerOwnedVehicles) then {
        missionNamespace setVariable ["BIS_WL_guerOwnedVehicles", _guerOwnedVehicles, true];
    };

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