#include "includes.inc"
params ["_vehicleType", "_spawnPos", "_direction", "_isStatic", "_isAircraft", "_vehicleUnits", "_sector"];

private _vehicle = [objNull, _spawnPos, _vehicleType, _direction, _isAircraft, _isAircraft] call WL2_fnc_orderGround;
_vehicleUnits pushBack _vehicle;

if (!_isStatic) then {
    private _group = createVehicleCrew _vehicle;
    private _crew = crew _vehicle;
    {
        _x call WL2_fnc_newAssetHandle;
        _vehicleUnits pushBack _x;
    } forEach _crew;

    [_group, 0] setWaypointPosition [_sector, 100];
    _group setBehaviour "COMBAT";
    _group deleteGroupWhenEmpty true;

    private _wp = _group addWaypoint [_sector, 100];
    _wp setWaypointType "SAD";

    _wp = _group addWaypoint [_sector, 100];
    _wp setWaypointType "CYCLE";

    _vehicle allowCrewInImmobile [true, true];
    [_vehicle, [1, 1, 1]] remoteExec ["setVehicleTIPars", 0];
};

if (_isAircraft) then {
    private _cmLaunchers = (weapons _vehicle) select {
        _x isKindOf ["CMFlareLauncher", configFile >> "CfgWeapons"];
    };
    if (count _cmLaunchers > 0) then {
        private _cmLauncher = _cmLaunchers # 0;
        _vehicle setVariable ["DIS_cmLauncher", _cmLauncher];
    };
};

_vehicle;