#include "includes.inc"
params ["_projectile", "_unit", "_mineLayerType"];

private _munitionList = _unit getVariable ["DIS_munitionList", []];
_munitionList pushBack _projectile;
_munitionList = _munitionList select { alive _x };
_unit setVariable ["DIS_munitionList", _munitionList];
_projectile setVariable ["WL2_missileType", "Deployer", true];
_projectile setVariable ["DIS_mineLayerType", _mineLayerType];

_projectile addEventHandler ["HitPart", {
    params ["_projectile", "_hitEntity", "_projectileOwner", "_position"];
    private _mineLayerType = _projectile getVariable ["DIS_mineLayerType", ""];
    if (_mineLayerType == "") exitWith {};

    private _projectilePosition = ASLtoAGL _position;
    private _projectileDirection = getDir _projectile;

    [player, "deployMineLayer", _projectilePosition, _projectileDirection, _mineLayerType] remoteExec ["WL2_fnc_handleClientRequest", 2];
    _projectile setVariable ["DIS_mineLayerType", ""];
}];