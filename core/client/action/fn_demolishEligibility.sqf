#include "includes.inc"

params ["_demolishableItems"];

if (cameraOn != player) exitWith { objNull };
if (!isTouchingGround player) exitWith { objNull };

if (count _demolishableItems == 0) exitWith { objNull };
if (count _demolishableItems > 1) then {
    _demolishableItems = [_demolishableItems, [], {
        if (_x == cursorTarget) then {
            -1
        } else {
            player distance _x
        };
    }, "ASCEND"] call BIS_fnc_sortBy;
};
private _demolishTarget = _demolishableItems # 0;

private _strongholdSector = _demolishTarget getVariable ["WL_strongholdSector", objNull];
if (isNull _strongholdSector) exitWith {
    private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];
    private _enableAlliedDemolition = _settingsMap getOrDefault ["enableAlliedDemolition", false];
    if (_enableAlliedDemolition) then {
        _demolishTarget
    } else {
        private _assetSide = [_demolishTarget] call WL2_fnc_getAssetSide;
        if (_assetSide == BIS_WL_playerSide) then {
            objNull
        } else {
            _demolishTarget
        };
    };
};
private _sectorOwner = _strongholdSector getVariable ["BIS_WL_owner", independent];

#if WL_STRONGHOLD_DEBUG == 0
if (_sectorOwner == BIS_WL_playerSide) exitWith { objNull };
#endif

private _strongholdRadius = _demolishTarget getVariable ["WL_strongholdRadius", 0];
private _strongholdArea = [
    getPosASL _demolishTarget,
    _strongholdRadius,
    _strongholdRadius,
    0,
    false
];
if !(player inArea _strongholdArea) exitWith { objNull };

private _nearbyEnemies = _strongholdArea nearEntities [["Man"], false, true, false];
_nearbyEnemies = _nearbyEnemies select {
    lifeState _x != "INCAPACITATED" &&
    side group _x != side group player
};

if (count _nearbyEnemies > 0) exitWith { objNull };
_demolishTarget;