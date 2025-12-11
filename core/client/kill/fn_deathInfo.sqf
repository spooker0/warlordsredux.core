#include "includes.inc"
params ["_unit", "_responsiblePlayer", "_killer"];

if (_unit != player || (alive player && lifeState player != "INCAPACITATED")) exitWith {};
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

private _isKillerAI = !(isPlayer _responsiblePlayer || isPlayer _killer) && _responsiblePlayerName != "???";
private _side = side group _unit;
private _killerSide = side group _responsiblePlayer;
if (_killerSide == sideUnknown) then {
    _killerSide = side group _killer;
};

private _damageDone = if (alive _killer && lifeState _killer != "INCAPACITATED") then {
    if (vehicle _killer isKindOf "Man") then {
        damage _killer;
    } else {
        damage vehicle _killer;
    };
} else {
    1;
};
private _health = round ((1 - _damageDone) * 100);

private _killerVehicle = uiNamespace getVariable ["WL2_damageSource", objNull];
if (isNull _killerVehicle) then {
    _killerVehicle = vehicle _killer;
};
private _killerWeapon = uiNamespace getVariable ["WL2_damagedWeapon", currentWeapon _killer];
if (_killerWeapon == "") then {
    _killerWeapon = currentWeapon _killer;
};

private _killerText = if (_killerVehicle isKindOf "Man") then {
    private _weaponText = getText (configfile >> "CfgWeapons" >> _killerWeapon >> "displayName");
    _weaponText;
} else {
    private _vehicleText = [_killerVehicle] call WL2_fnc_getAssetTypeName;
    _vehicleText;
};

private _killerIcon = if (_killerVehicle isKindOf "Man") then {
    private _weaponIcon = getText (configfile >> "CfgWeapons" >> _killerWeapon >> "picture");
    _weaponIcon;
} else {
    private _vehicleIcon = getText (configfile >> "CfgVehicles" >> typeOf _killerVehicle >> "picture"); // use spawned vehicle type
    if (_vehicleIcon in ["pictureThing", "pictureStaticObject"]) then {
        _vehicleIcon = "a3\ui_f\data\map\vehicleicons\iconcratesupp_ca.paa";
    };
    _vehicleIcon;
};

private _killerTextArray = toArray _killerText;
{
    if (_x == 160) then {
        _killerTextArray set [_forEachIndex, 32];
    };
} forEach _killerTextArray;
_killerText = toString _killerTextArray;

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

private _badgeText = if (isPlayer _responsiblePlayer) then {
    _responsiblePlayer getVariable ["WL2_currentBadge", "Player"];
} else {
    "AI";
};

private _badgeConfigs = call RWD_fnc_getBadgeConfigs;
private _badgeData = _badgeConfigs getOrDefault [_badgeText, []];
private _badgeLevel = if (count _badgeData > 0) then {
    _badgeData select 1;
} else {
    1;
};

private _badgeIcon = if (count _badgeData > 0) then {
    _badgeData select 0;
} else {
    "";
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

private _gameData = [
    _health,
    _killerText,
    _killerIcon regexReplace ["^\\", ""],
    _ratioYou,
    _ratioThem,
    _responsiblePlayerName,
    str _killerSide,
    _badgeText,
    _badgeLevel,
    _badgeIcon,
    _hitPoints,
    _projectileHitArray
];

uiNamespace setVariable ["WL2_deathInfoData", _gameData];
uiNamespace setVariable ["WL2_deadActionId", 0];

private _display = uiNamespace getVariable ["RscWLDeathInfoMenu", displayNull];
if (isNull _display) then {
    private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];
    private _showDeathInfoInMap = _settingsMap getOrDefault ["showDeathInfoInMap", false];

    "deathInfo" cutRsc ["RscWLDeathInfoMenu", "PLAIN", -1, _showDeathInfoInMap, true];
    _display = uiNamespace getVariable "RscWLDeathInfoMenu";
};
private _texture = _display displayCtrl 5502;

_texture ctrlAddEventHandler ["PageLoaded", {
    params ["_texture"];
    private _gameData = uiNamespace getVariable ["WL2_deathInfoData", []];

    private _deathInfoText = toJSON _gameData;
    _deathInfoText = _texture ctrlWebBrowserAction ["ToBase64", _deathInfoText];

    private _script = format ["updateData(atobr(""%1""));", _deathInfoText];
    _texture ctrlWebBrowserAction ["ExecJS", _script];

    _this spawn {
        params ["_texture"];
        while { !isNull _texture } do {
            private _expirationTime = player getVariable ["WL2_expirationTime", 0];
            private _respawnTimer = (_expirationTime - serverTime) max 0;

            private _respawnDisplay = if (!alive player) then {
                ""
            } else {
                _respawnTimer toFixed 1
            };
            private _script = format ["updateRespawnTimer(""%1"");", _respawnDisplay];
            _texture ctrlWebBrowserAction ["ExecJS", _script];

            uiSleep 0.1;
        };

        uiNamespace setVariable ["WL2_damagedProjectiles", createHashMap];
        uiNamespace setVariable ["WL2_damageSource", objNull];
        uiNamespace setVariable ["WL2_damagedWeapon", nil];
    };
}];

_texture ctrlAddEventHandler ["JSDialog", {
    params ["_texture", "_isConfirmDialog", "_message"];
    if (_message == "HOLD ON") then {
        private _currentExpirationTime = player getVariable ["WL2_expirationTime", 0];
        _currentExpirationTime = (_currentExpirationTime + 5) min (serverTime + 30);
        player setVariable ["WL2_expirationTime", _currentExpirationTime, true];

        private _crawlSounds = [];
        for "_i" from 1 to 5 do {
            _crawlSounds pushBack format ["a3\sounds_f\characters\crawl\concrete_crawl_%1.wss", _i];
        };
        playSoundUI [selectRandom _crawlSounds];

        0 spawn {
            private _playerHelpCall = player getVariable ["WL2_playerHelpCall", objNull];
            if (!alive _playerHelpCall) exitWith {
                private _soundSource = createSoundSource ["WLDownedSound", player modelToWorld [0, 0, 0], [], 0];
                player setVariable ["WL2_playerHelpCall", _soundSource];

                while { alive player && lifeState player == "INCAPACITATED" } do {
                    uiSleep 0.1;
                };

                deleteVehicle _soundSource;
            };
        };
    };
    true;
}];

waitUntil {
    uiSleep 0.1;
    (alive player && lifeState player != "INCAPACITATED") || WL_IsSpectator || BIS_WL_missionEnd;
};

"deathInfo" cutText ["", "PLAIN"];