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
            systemTimeUTC
        ];
        _chatHistory pushBack _chatMessage;
    };
};

if (_sentLocally && _text == "!lag") exitWith {
    [player] remoteExec ["WL2_fnc_lagMessageHandler", 2];
    true;
};

if (_sentLocally && _text == "!lowfps") exitWith {
    0 spawn {
        private _messageTemplate = "Client Script Collector";
        private _message = [_messageTemplate] call WL2_fnc_scriptCollector;
        [_message] call WL2_fnc_lagMessageDisplay;
    };
    true;
};

if (_sentLocally && _isAdmin && _text == "!updateZeus") exitWith {
    [player, 'updateZeus'] remoteExec ['WL2_fnc_handleClientRequest', 2];
    true;
};

// Hide for remote players
if (_text in ["!lag", "!lowfps", "!updateZeus"]) exitWith {
    true;
};

private _passedName = uiNamespace getVariable ["MODR_passedName", ""];
if (_channel == 16 || _channel == 17) then {
    private _regexMatches = _text regexMatch "[\s]?.*[\d]+[\s]+([\w]{32,32})[\s]{1,1}(.*)$";
    private _hasName = [_passedName, _text] call BIS_fnc_inString;
    if (_regexMatches && _hasName) then {
        private _reportLine = _text regexFind ["([\w]{32})[\s]{1}(.*)$",10];
        if (count _reportLine > 0) then {
            private _beId = _reportLine # 0 # 1 # 0;
            uiNamespace setVariable ["MODR_returnedBeId", _beId];
        };
    };
};

private _showInSquadChat = ["showInSquadChat", [_person, _channel]] call SQD_fnc_client;
if (!_showInSquadChat) exitWith {
    true;
};

private _killMessaage = _chatMessageType == 2;
if (_killMessaage) exitWith {
    true;
};

private _disallowList = getArray (missionConfigFile >> "adminFilter");
private _filteredText = _text;
{
    _filteredText = _filteredText regexReplace [_x, "\*\*\*"];
} forEach _disallowList;

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

_filteredText;