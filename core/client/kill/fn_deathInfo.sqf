#include "includes.inc"
params ["_unit", "_responsiblePlayer", "_killer"];

if (_unit != player || WL_ISUP(player)) exitWith {};
if ((_killer == _unit || isNull _killer) && !isNull _responsiblePlayer) then {
    _killer = _responsiblePlayer;
};

private _responsiblePlayerName = if (!isNull _responsiblePlayer) then {
    name _responsiblePlayer;
} else {
    if (!isNull _killer) then {
        name _killer;
    } else {
        "???";
    };
};

private _killerVehicle = uiNamespace getVariable ["WL2_damageSource", objNull];
if (isNull _killerVehicle) then {
    _killerVehicle = vehicle _killer;
};
private _killerWeapon = uiNamespace getVariable ["WL2_damagedWeapon", ""];
if (_killerWeapon == "") then {
    _killerWeapon = currentWeapon _killerVehicle;
};

private _killerText = if (_killerVehicle isKindOf "Man") then {
    private _weaponText = getText (configfile >> "CfgWeapons" >> _killerWeapon >> "displayName");
    _weaponText;
} else {
    private _vehicleText = [_killerVehicle] call WL2_fnc_getAssetTypeName;
    _vehicleText;
};

private _responsiblePlayerUid = if (!isNull _responsiblePlayer) then {
    getPlayerUID _responsiblePlayer
} else {
    ""
};

private _ratioYou = 0;
private _ratioThem = 0;
if (_responsiblePlayerUid != "") then {
    private _killedByMap = missionNamespace getVariable ["WL2_killedBy", createHashMap];
    private _timesKilledBy = _killedByMap getOrDefault [_responsiblePlayerUid, 0];
    _timesKilledBy = _timesKilledBy + 1;
    _killedByMap set [_responsiblePlayerUid, _timesKilledBy];
    missionNamespace setVariable ["WL2_killedBy", _killedByMap];

    private _timesKilledMap = missionNamespace getVariable ["WL2_killed", createHashMap];
    private _timesKilled = _timesKilledMap getOrDefault [_responsiblePlayerUid, 0];

    _ratioYou = _timesKilled;
    _ratioThem = _timesKilledBy;
};

private _hitPoints = (getAllHitPointsDamage player) select 2;
private _hitProjectiles = uiNamespace getVariable ["WL2_damagedProjectiles", createHashMap];
private _projectileHitArray = [];
{
    _projectileHitArray pushBack [_x, _y];
} forEach _hitProjectiles;
_projectileHitArray = [_projectileHitArray, [], { _x # 0 }, "DESCEND"] call BIS_fnc_sortBy;
_projectileHitArray = (_projectileHitArray select {
    private _timeAgo = diag_tickTime - (_x # 0);
    _timeAgo < 300
} select [0, 20]) apply {
    private _timeAgo = diag_tickTime - (_x # 0);
    [format ["-%1", round (_timeAgo * 1000)], _x # 1]
};

uiNamespace setVariable ["WL2_deathInfoData", [
    _responsiblePlayerName,
    _killerText,
    _ratioYou,
    _ratioThem,
    _projectileHitArray
]];

private _deathInfoDisplay = call SQD_fnc_initDeathInfo;

private _endDeathInfoTime = serverTime + 10;
waitUntil {
    uiSleep 0.1;
    WL_ISUP(player) || WL_IsSpectator || BIS_WL_missionEnd || serverTime > _endDeathInfoTime || isNull _deathInfoDisplay;
};

0 spawn SQD_fnc_initSquadMenu;

waitUntil {
    uiSleep 0.1;
    WL_ISUP(player) || WL_IsSpectator || BIS_WL_missionEnd;
};

private _existingDisplay = findDisplay 10000;
if (!isNull _existingDisplay) then {
    _existingDisplay closeDisplay 0;
};