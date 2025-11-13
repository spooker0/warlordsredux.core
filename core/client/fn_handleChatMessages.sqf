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

// if (_sentLocally && count allPlayers < 20 && count _params > 0 && {_params # 0 == "$STR_DS_VOTES_KICK"}) then {
//     [player, getPlayerUID player, "vote kick not allowed", 120] remoteExec ["WL2_fnc_punishPlayer", 2];
// };

// if (_sentLocally && _channel in [0, 1, 2, 3] && _text != "" && !_isPlayerMessage && _person == player && count _params == 0) then {
//     private _spamHistory = uiNamespace getVariable ["WL2_spamHistory", []];
//     private _spammedMessages = _spamHistory select {
//         _x # 0 == _text &&
//         serverTime - (_x # 1) < 120
//     };

//     if (count _spammedMessages >= 3) then {
//         {
//             private _vonStatus = (channelEnabled _x) # 1;
//             _x enableChannel [false, _vonStatus];
//         } forEach [0, 1, 3];

//         systemChat "Spam protection triggered. Chat disabled for 30s.";
//         0 spawn {
//             uiSleep 30;
//             {
//                 private _vonStatus = (channelEnabled _x) # 1;
//                 _x enableChannel [true, _vonStatus];
//             } forEach [0, 1, 3];
//         };
//     };

//     _spamHistory pushBack [_text, serverTime];
//     _spamHistory = _spamHistory select {
//         serverTime - (_x # 1) < 120
//     };
//     uiNamespace setVariable ["WL2_spamHistory", _spamHistory];
// };

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

private _isBattleyeMessage = false;
if (_channel == 16 || _channel == 17) then {
    private _regexMatches = _text regexFind ["[\s]?.*[\d]+[\s]+([\w]{32,32})[\s]{1,1}(.*)$"];
    if (count _regexMatches > 0 && {count (_regexMatches # 0) >= 3}) exitWith {
        private _beId = _regexMatches # 0 # 1 # 0;
        private _beName = _regexMatches # 0 # 2 # 0;
        private _guidMap = uiNamespace getVariable ["WL2_guidMap", createHashMap];
        _guidMap set [_beName, _beId];
        uiNamespace setVariable ["WL2_guidMap", _guidMap];
        _isBattleyeMessage = true;
    };
    if (_text == "BattlEye Client: Players on server:") exitWith {
        _isBattleyeMessage = true;
    };
    if (_text == "  [#] [Ping] [GUID] [Name]") exitWith {
        _isBattleyeMessage = true;
    };
    if (_text == "  ------------------------------") exitWith {
        _isBattleyeMessage = true;
    };
    if (_text regexMatch ".*\([\d]+ players in total\)") exitWith {
        _isBattleyeMessage = true;
    };
};
if (_isBattleyeMessage) exitWith {
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
    private _playerLevel = _person getVariable ["WL_playerLevel", "Recruit"];
    private _newFrom = format ["%1 [%2]", _from, _playerLevel];
    [_newFrom, _filteredText];
};

if (_channel == 1) exitWith {
    private _playerLevel = _person getVariable ["WL_playerLevel", "Recruit"];
    private _newFrom = format ["%1 [%2]", _name, _playerLevel];
    [_newFrom, _filteredText];
};

if (_channel > 5 && _channel < 16) then {
    private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];
    private _volume = _settingsMap getOrDefault ["squadChatNotificationVolume", 1];
    playSoundUI ["a3\missions_f_oldman\data\sound\phone_sms\chime\phone_sms_chime_04.wss", _volume, 1];
};

_filteredText;