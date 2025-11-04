#include "includes.inc"

if (isWeaponDeployed player) exitWith {
    [false, "Bipod must not be deployed."];
};

// Make sure to update cancel vehicle order as well
private _enemiesNearPlayer = (allUnits inAreaArray [player, 150, 150]) select {
    _x isKindOf "Man"
} select {
    BIS_WL_playerSide != side group _x
} select {
    _x != player
} select {
    alive _x && lifeState _x != "INCAPACITATED"
} select {
    isTouchingGround _x
} select {
    private _position = getPosASL _x;
    !(surfaceIsWater _position) || (_position # 2 > 20 && _position # 2 < 30)
};

private _homeBase = BIS_WL_playerSide call WL2_fnc_getSideBase;
private _isInHomeBase = player inArea (_homeBase getVariable "objectAreaComplete");
private _nearbyEnemies = count _enemiesNearPlayer > 0 && !_isInHomeBase;

if (_nearbyEnemies) then {
    [false, "There are enemies nearby."];
} else {
    [true, ""];
};