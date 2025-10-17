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

private _killerColor = switch (_killerSide) do {
    case (west): {
        "#00008b";
    };
    case (east): {
        "#8b0000";
    };
    case (independent): {
        "#008b00";
    };
    default {
        "#ffffff";
    };
};

private _detectedBySensors = switch (_killerSide) do {
    case (west): {
        listRemoteTargets west;
    };
    case (east): {
        listRemoteTargets east;
    };
    case (independent): {
        listRemoteTargets independent;
    };
    default {
        [];
    };
};
private _findDetection = _detectedBySensors select { _x # 0 == vehicle _unit || _x # 0 == _unit };
private _detectSensorText = if (count _findDetection > 0) then {
    localize "STR_A3_WL_detected_by_sensors";
} else {
    private _detectedByAI = switch (_killerSide) do {
        case (west): {
            west knowsAbout _unit;
        };
        case (east): {
            east knowsAbout _unit;
        };
        case (independent): {
            0;  // independents are always AI anyway
        };
        default {
            0;
        };
    };

    if (_detectedByAI >= 1.5 && _killerSide != _side && !_isKillerAI) then {
        localize "STR_A3_WL_detected_by_AI";
    } else {
        "";
    };
};

private _damageDone = if (alive _killer) then {
    if (vehicle _killer isKindOf "Man") then {
        damage _killer;
    } else {
        damage vehicle _killer;
    };
} else {
    1;
};
private _health = round ((1 - _damageDone) * 100);

private _distance = round (_killer distance _unit);
private _distanceText = switch (true) do {
    case (_distance < 100): {
        "CQB";
    };
    case (_distance < 1000): {
        "NEAR";
    };
    case (_distance < 10000): {
        "FAR";
    };
    default {
        "DISTANT";
    };
};

private _killerVehicle = vehicle _killer;
private _killerWeapon = currentWeapon _killer;

private _killerText = if (vehicle _killer isKindOf "Man") then {
    private _weaponText = getText (configfile >> "CfgWeapons" >> _killerWeapon >> "displayName");
    _weaponText;
} else {
    private _vehicleText = [_killerVehicle] call WL2_fnc_getAssetTypeName;
    _vehicleText;
};

private _killerIcon = if (vehicle _killer isKindOf "Man") then {
    private _weaponIcon = getText (configfile >> "CfgWeapons" >> _killerWeapon >> "picture");
    _weaponIcon;
} else {
    private _vehicleIcon = getText (configfile >> "CfgVehicles" >> typeOf _killerVehicle >> "picture"); // use spawned vehicle type
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

private _ratioText = "0 - 0";
if (_responsiblePlayerUid != "") then {
    private _killedByMap = missionNamespace getVariable ["WL2_killedBy", createHashMap];
    private _timesKilledBy = _killedByMap getOrDefault [_responsiblePlayerUid, 0];
    _timesKilledBy = _timesKilledBy + 1;
    _killedByMap set [_responsiblePlayerUid, _timesKilledBy];
    missionNamespace setVariable ["WL2_killedBy", _killedByMap];

    private _timesKilledMap = missionNamespace getVariable ["WL2_killed", createHashMap];
    private _timesKilled = _timesKilledMap getOrDefault [_responsiblePlayerUid, 0];

    _ratioText = format ["%1 - %2", _timesKilled, _timesKilledBy];
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

private _gameData = [
    _health,
    _killerText,
    _killerIcon regexReplace ["^\\", ""],
    _distanceText,
    _ratioText,
    _detectSensorText,
    _responsiblePlayerName,
    _killerColor,
    _badgeText,
    _badgeLevel,
    _badgeIcon
];

uiNamespace setVariable ["WL2_deathInfoData", _gameData];

private _display = uiNamespace getVariable ["RscWLDeathInfoMenu", displayNull];
if (isNull _display) then {
    "deathInfo" cutRsc ["RscWLDeathInfoMenu", "PLAIN", -1, true, true];
    _display = uiNamespace getVariable "RscWLDeathInfoMenu";
};
private _texture = _display displayCtrl 5502;

_texture ctrlAddEventHandler ["PageLoaded", {
    params ["_texture"];
    private _gameData = uiNamespace getVariable ["WL2_deathInfoData", []];

    private _deathInfoText = toJSON _gameData;
    _deathInfoText = _texture ctrlWebBrowserAction ["ToBase64", _deathInfoText];

    private _script = format ["updateData(atob(""%1""));", _deathInfoText];
    _texture ctrlWebBrowserAction ["ExecJS", _script];

    _this spawn {
        params ["_texture"];
        while { !isNull _texture } do {
            private _downedLiveTime = player getVariable ["WL2_downedLiveTime", 25];
            private _downedTime = player getVariable ["WL_unconsciousTime", 0];
            private _respawnTimer = _downedLiveTime - _downedTime;

            private _script = format ["updateRespawnTimer(""%1"");", _respawnTimer toFixed 1];
            _texture ctrlWebBrowserAction ["ExecJS", _script];

            uiSleep 0.1;
        };
    };
}];

waitUntil {
    uiSleep 0.1;
    !alive player
};

"deathInfo" cutText ["", "PLAIN"];