#include "includes.inc"

if (isWeaponDeployed player) exitWith {
    [false, "Bipod must not be deployed."];
};

private _enemiesNearPlayer = (allPlayers inAreaArray [player, 175, 175]) select {
    BIS_WL_playerSide != side group _x
} select {
    _x != player
} select {
    alive _x && lifeState _x != "INCAPACITATED"
} select {
    isTouchingGround _x
};

private _homeBase = BIS_WL_playerSide call WL2_fnc_getSideBase;
private _isInHomeBase = player inArea (_homeBase getVariable "objectAreaComplete");
private _nearbyEnemies = count _enemiesNearPlayer > 0 && !_isInHomeBase;

if (_nearbyEnemies) then {
    [false, "There are enemies nearby."];
} else {
    [true, ""];
};