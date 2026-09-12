#include "includes.inc"
params ["_projectile", "_unit", "_mineLayerType"];

private _projectilePosition = getPosATL _projectile;
private _projectileDirection = getDir _projectile;
deleteVehicle _projectile;

uiSleep 3;

private _parachuteClass = switch (BIS_WL_playerSide) do {
    case west: { "B_Parachute_02_F" };
    case east: { "O_Parachute_02_F" };
    case independent: { "I_Parachute_02_F" };
};

if (_projectilePosition # 2 < 50) then {
    _projectilePosition set [2, 50];
};

private _container = createVehicle ["SpaceshipCapsule_01_container_F", _projectilePosition, [], 0, "NONE"];
_container setPosATL _projectilePosition;
private _altitude = (getPosVisual _container) # 2;

private _munitionList = _unit getVariable ["DIS_munitionList", []];
_munitionList pushBack _container;
_munitionList = _munitionList select { alive _x };
_unit setVariable ["DIS_munitionList", _munitionList];
_container setVariable ["WL2_missileType", "Deployer", true];

uiSleep 3;

private _parachute = createVehicle [_parachuteClass, _container modelToWorld [0, 0, 20], [], 0, "NONE"];
_parachute setDir _projectileDirection;
_container attachTo [_parachute, [0, 0, 0]];

while { _altitude > 5 && alive _container && alive _parachute } do {
    uiSleep 0.01;
    _parachute setVectorUp [0, 0, 1];

    private _speed = if (_altitude < 100) then { 5 } else { 50 };
    _parachute setVelocityModelSpace [0, 0, -_speed];

    _altitude = (getPosVisual _container) # 2;
};

private _dispenseSounds = [
    "a3\sounds_f_orange\arsenal\explosives\minedispenser\minedispenser_launch_01.wss",
    "a3\sounds_f_orange\arsenal\explosives\minedispenser\minedispenser_launch_02.wss",
    "a3\sounds_f_orange\arsenal\explosives\minedispenser\minedispenser_launch_03.wss",
    "a3\sounds_f_orange\arsenal\explosives\minedispenser\minedispenser_launch_04.wss"
];
private _finalPosition = [_projectilePosition # 0, _projectilePosition # 1, 0];
playSound3D [selectRandom _dispenseSounds, objNull, false, _finalPosition, 3];

deleteVehicle _container;
deleteVehicle _parachute;

[player, "deployMineLayer", _finalPosition, _projectileDirection, _mineLayerType] remoteExec ["WL2_fnc_handleClientRequest", 2];