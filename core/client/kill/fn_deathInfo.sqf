#include "includes.inc"
params ["_unit", "_responsiblePlayer", "_killer"];

if (_unit != player || WL_ISUP(player)) exitWith {};
if ((_killer == _unit || isNull _killer) && !isNull _responsiblePlayer) then {
    _killer = _responsiblePlayer;
};

0 spawn SQD_fnc_initSquadMenu;

// private _responsiblePlayerName = if (!isNull _responsiblePlayer) then {
//     name _responsiblePlayer;
// } else {
//     if (!isNull _killer) then {
//         name _killer;
//     } else {
//         "???";
//     };
// };

// private _isKillerAI = !(isPlayer _responsiblePlayer || isPlayer _killer) && _responsiblePlayerName != "???";
// private _side = side group _unit;
// private _killerSide = side group _responsiblePlayer;
// if (_killerSide == sideUnknown) then {
//     _killerSide = side group _killer;
// };

// private _damageDone = if (WL_ISUP(_killer)) then {
//     if (vehicle _killer isKindOf "Man") then {
//         damage _killer;
//     } else {
//         damage vehicle _killer;
//     };
// } else {
//     1;
// };
// private _health = round ((1 - _damageDone) * 100);

// private _killerVehicle = uiNamespace getVariable ["WL2_damageSource", objNull];
// if (isNull _killerVehicle) then {
//     _killerVehicle = vehicle _killer;
// };
// private _killerWeapon = uiNamespace getVariable ["WL2_damagedWeapon", ""];
// if (_killerWeapon == "") then {
//     _killerWeapon = currentWeapon _killerVehicle;
// };

// private _killerText = if (_killerVehicle isKindOf "Man") then {
//     private _weaponText = getText (configfile >> "CfgWeapons" >> _killerWeapon >> "displayName");
//     _weaponText;
// } else {
//     private _vehicleText = [_killerVehicle] call WL2_fnc_getAssetTypeName;
//     _vehicleText;
// };

// private _killerIcon = if (_killerVehicle isKindOf "Man") then {
//     private _weaponIcon = getText (configfile >> "CfgWeapons" >> _killerWeapon >> "picture");
//     _weaponIcon;
// } else {
//     private _vehicleIcon = getText (configfile >> "CfgVehicles" >> typeOf _killerVehicle >> "picture"); // use spawned vehicle type
//     if (_vehicleIcon in ["pictureThing", "pictureStaticObject"]) then {
//         _vehicleIcon = "a3\ui_f\data\map\vehicleicons\iconcratesupp_ca.paa";
//     };
//     _vehicleIcon;
// };

// private _killerTextArray = toArray _killerText;
// {
//     if (_x == 160) then {
//         _killerTextArray set [_forEachIndex, 32];
//     };
// } forEach _killerTextArray;
// _killerText = toString _killerTextArray;

// private _responsiblePlayerUid = if (!isNull _responsiblePlayer) then {
//     getPlayerUID _responsiblePlayer
// } else {
//     ""
// };

// private _ratioYou = 0;
// private _ratioThem = 0;
// if (_responsiblePlayerUid != "") then {
//     private _killedByMap = missionNamespace getVariable ["WL2_killedBy", createHashMap];
//     private _timesKilledBy = _killedByMap getOrDefault [_responsiblePlayerUid, 0];
//     _timesKilledBy = _timesKilledBy + 1;
//     _killedByMap set [_responsiblePlayerUid, _timesKilledBy];
//     missionNamespace setVariable ["WL2_killedBy", _killedByMap];

//     private _timesKilledMap = missionNamespace getVariable ["WL2_killed", createHashMap];
//     private _timesKilled = _timesKilledMap getOrDefault [_responsiblePlayerUid, 0];

//     _ratioYou = _timesKilled;
//     _ratioThem = _timesKilledBy;
// };

// private _badgeText = if (isPlayer _responsiblePlayer) then {
//     _responsiblePlayer getVariable ["WL2_currentBadge", "Player"];
// } else {
//     "AI";
// };

// private _badgeConfigs = call RWD_fnc_getBadgeConfigs;
// private _badgeData = _badgeConfigs getOrDefault [_badgeText, []];
// private _badgeLevel = if (count _badgeData > 0) then {
//     _badgeData select 1;
// } else {
//     1;
// };

// private _badgeIcon = if (count _badgeData > 0) then {
//     _badgeData select 0;
// } else {
//     "";
// };

// private _hitPoints = (getAllHitPointsDamage player) select 2;
// private _hitProjectiles = uiNamespace getVariable ["WL2_damagedProjectiles", createHashMap];
// private _projectileHitArray = [];
// {
//     _projectileHitArray pushBack [_x, _y];
// } forEach _hitProjectiles;
// _projectileHitArray = [_projectileHitArray, [], { _x # 0 }, "DESCEND"] call BIS_fnc_sortBy;
// _projectileHitArray = (_projectileHitArray select {
//     private _timeAgo = diag_tickTime - (_x # 0);
//     _timeAgo < 300
// } select [0, 20]) apply {
//     private _timeAgo = diag_tickTime - (_x # 0);
//     [format ["-%1", round (_timeAgo * 1000)], _x # 1]
// };

// private _gameData = [
//     _health,
//     _killerText,
//     _killerIcon regexReplace ["^\\", ""],
//     _ratioYou,
//     _ratioThem,
//     _responsiblePlayerName,
//     str _killerSide,
//     _badgeText,
//     _badgeLevel,
//     _badgeIcon,
//     _hitPoints,
//     _projectileHitArray
// ];

// uiNamespace setVariable ["WL2_deathInfoData", _gameData];

waitUntil {
    uiSleep 0.1;
    WL_ISUP(player) || WL_IsSpectator || BIS_WL_missionEnd;
};

private _existingDisplay = findDisplay 10000;
if (!isNull _existingDisplay) then {
    _existingDisplay closeDisplay 0;
};