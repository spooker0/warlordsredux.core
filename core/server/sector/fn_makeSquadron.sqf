#include "includes.inc"
params ["_originPlayer", "_distance"];

#if WL_TEST_SERVER == 0
if (true) exitWith {};
#endif

if (!isServer) exitWith {};

private _aircraftPool = [];
{
    private _class = _x;
    private _data = _y;
    private _aircraftSpawn = _data getOrDefault ["aircraftSpawn", 0];
    if (_aircraftSpawn > 0) then {
        _aircraftPool pushBack _class;
    };
} forEach WL_ASSET_DATA;

private _vehicleUnits = [];
for "_i" from 1 to 4 do {
    private _randomAngle = random 360;
    private _randomDistance = _distance - random (_distance / 2);
    private _randomPos = _originPlayer getPos [_randomDistance, _randomAngle];
    _randomPos set [2, 1000];

    private _aircraft = [selectRandom _aircraftPool, _randomPos, random 360, false, true, _vehicleUnits, _originPlayer] call WL2_fnc_addGreenVehicle;
    _aircraft setPosASL _randomPos;
    _aircraft setVelocityModelSpace [0, 100, 0];
    _aircraft flyInHeightASL [1000, 1000, 1000];
};

[_vehicleUnits, 3600] remoteExec ["WL2_fnc_reportTargets", BIS_WL_playerSide];

private _ownedVehicles = missionNamespace getVariable ["BIS_WL_ownedVehicles_server", []];
_ownedVehicles append _vehicleUnits;
missionNamespace setVariable ["BIS_WL_ownedVehicles_server", _ownedVehicles];