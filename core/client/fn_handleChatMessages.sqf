#include "includes.inc"
params ["_channel", "_owner", "_from", "_text", "_person", "_name", "_strID", "_forcedDisplay", "_isPlayerMessage", "_sentenceType", "_chatMessageType", "_params"];

private _sentLocally = _owner == clientOwner;
private _uid = getPlayerUID player;
private _isAdmin = _uid in (getArray (missionConfigFile >> "adminIDs"));
private _isModerator = _uid in (getArray (missionConfigFile >> "moderatorIDs"));

if (_isModerator || _isAdmin) then {
    private _chatHistory = uiNamespace getVariable ["WL2_chatHistory", []];
    if (count _chatHistory == 0) then {
        uiNamespace setVariable ["WL2_chatHistory", _chatHistory];
    };

    if (_text != "") then {
        private _chatMessage = [
            _channel,
            _name,
            _text,
            systemTime
        ];
        _chatHistory pushBack _chatMessage;
    };
};

if (_text == "!lag") exitWith {
    if (_sentLocally) then {
        [player] remoteExec ["WL2_fnc_lagMessageHandler", 2];
    };
    true;
};

if (_text == "!lowfps") exitWith {
    if (_sentLocally) then {
        0 spawn {
            private _messageTemplate = "Client Script Collector";
            private _message = [_messageTemplate] call WL2_fnc_scriptCollector;
            [_message] call WL2_fnc_lagMessageDisplay;
        };
    };
    true;
};

if (_text == "!updateZeus") exitWith {
    if (_sentLocally && _isAdmin) then {
        [player, 'updateZeus'] remoteExec ['WL2_fnc_handleClientRequest', 2];
    };
    true;
};

if (_text == "!nfz") exitWith {
    if (_sentLocally) then {
        0 spawn WL2_fnc_nearestCombatAir;
    };
    true;
};

if (_text == "!aa") exitWith {
    if (_sentLocally) then {
        openMap true;
        player selectDiarySubject format ["%1:Record2", localize "STR_WL_missionName"];
    };
    true;
};

if (_text == "!capture") exitWith {
    if (_sentLocally) then {
        openMap true;
        player selectDiarySubject format ["%1:Record3", localize "STR_WL_missionName"];
    };
    true;
};

if (_text in ["!help", "!info"]) exitWith {
    if (_sentLocally) then {
        openMap true;
        player selectDiarySubject (localize "STR_WL_missionName");
    };
    true;
};

if (_text select [0, 2] == "!s") exitWith {
    if (_sentLocally) then {
        private _settingQuery = _text select [2];
        [format ["#%1", _settingQuery]] spawn MENU_fnc_settingsMenuInit;
    };
    true;
};

private _killMessage = _chatMessageType == 2;
if (_killMessage) exitWith {
    true;
};

private _disallowList = getArray (missionConfigFile >> "adminFilter");
private _filteredText = _text;
{
    _filteredText = _filteredText regexReplace [_x, "\*\*\*"];
} forEach _disallowList;

if (isNull _person) exitWith {
    _filteredText;
};

if (_channel == 0) exitWith {
    if (isPlayer _person && side group _person == independent) then {
        private _newFrom = format ["Lobby (%1)", _name];
        [_newFrom, _filteredText];
    } else {
        private _playerLevel = _person getVariable ["WL_playerLevel", "Recruit"];
        private _newFrom = format ["%1 [%2]", _from, _playerLevel];
        [_newFrom, _filteredText];
    };
};

if (_channel == 1) exitWith {
    private _playerLevel = _person getVariable ["WL_playerLevel", "Recruit"];
    private _newFrom = format ["%1 [%2]", _name, _playerLevel];
    [_newFrom, _filteredText];
};

if (_channel == 2) exitWith {
    private _playerSquad = ["getSquadForPlayer", [getPlayerID _person]] call SQD_fnc_query;
    private _playerSquadName = _playerSquad getOrDefault ["name", "???"];
    private _newFrom = format ["%1 [%2]", _name, _playerSquadName];

    if ("@TEAM" in (toUpper _filteredText)) then {
        private _settingsMap = missionProfileNamespace getVariable ["WL2_settings", createHashMap];
        private _volume = _settingsMap getOrDefault ["squadChatNotificationVolume", 1];
        playSoundUI ["a3\missions_f_oldman\data\sound\phone_sms\chime\phone_sms_chime_05.wss", _volume];
    };

    [_newFrom, _filteredText];
};

if (_channel > 5 && _channel != 16 && _filteredText != "") then {
    private _isPlayerSquadLeader = ["isSquadLeader", [getPlayerID player]] call SQD_fnc_query;
    private _isDirectNotification = (_isPlayerSquadLeader && "@SL" in (toUpper _filteredText)) || "@SQUAD" in (toUpper _filteredText);

    private _settingsMap = missionProfileNamespace getVariable ["WL2_settings", createHashMap];
    private _volume = if (_isDirectNotification) then {
        _settingsMap getOrDefault ["squadImportantNotificationVolume", 1];
    } else {
        _settingsMap getOrDefault ["squadChatNotificationVolume", 1];
    };
    playSoundUI ["a3\missions_f_oldman\data\sound\phone_sms\chime\phone_sms_chime_04.wss", _volume, 1];
};

_filteredText;