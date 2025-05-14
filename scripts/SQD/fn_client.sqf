#include "squad_constants.inc"

params ["_action", "_params"];

private _squadManager = missionNamespace getVariable ["SQUAD_MANAGER", []];
private _mySquadNumber = _squadManager findIf {(_x select 2) find (getPlayerID player) > -1};
private _allPlayers = call BIS_fnc_listPlayers;

_return = nil;

switch (_action) do {
    case "create": {
        private _squadName = profileNamespace getVariable ["SQD_nameDefault", format ["%1 SQUAD", toUpper (name player)]];
        private _leader = getPlayerID player;
        private _side = side player;

        ctrlShow [CREATE_BUTTON, false];

        ["TaskCreateSquad"] call WLT_fnc_taskComplete;

        ["create", [_squadName, _leader, _side]] remoteExec ["SQD_fnc_server", 2];
    };
    case "leave": {
        if (_mySquadNumber == -1) exitWith {
            _return = 1;
        };

        ctrlShow [LEAVE_BUTTON, false];

        ["TaskLeaveSquad"] call WLT_fnc_taskComplete;

        ["remove", [getPlayerID player]] remoteExec ["SQD_fnc_server", 2];
    };
    case "invite": {
        if (_mySquadNumber == -1) exitWith {
            _return = 1;
        };

        private _selection = lbCurSel PLAYER_LIST;
        if (isNil "_selection") exitWith {
            _return = 1;
        };

        private _player = lbData [PLAYER_LIST, _selection];
        private _inviter = getPlayerID player;

        ["invite", [_player, _inviter]] remoteExec ["SQD_fnc_server", 2];

        private _playerName = lbText [PLAYER_LIST, _selection];
        systemChat format [localize "STR_SQUADS_sendInvitationSuccessText", _playerName];

        playSoundUI ["a3\ui_f\data\sound\cfgnotifications\tasksucceeded.wss"];
    };
    case "invited": {
        // input: inviter id
        private _inviter = _params select 0;

        if (WL_IsSpectator) exitWith {
            _return = 1;
        };

        private _squadHasInvite = missionNamespace getVariable ["SQD_playerHasInvite", false];
        if (_squadHasInvite) exitWith {
            _return = 1;
        };
        missionNamespace setVariable ["SQD_playerHasInvite", true];

        private _squad = _squadManager select { (_x select 2) find _inviter > -1 };
        if (count _squad == 0) exitWith {
            _return = 1;
        };
        _squad = _squad # 0;
        private _inviterPlayer = _allPlayers select { getPlayerID _x == _inviter };
        private _inviterName = if (count _inviterPlayer == 0) then {
            "???"
        } else {
            name (_inviterPlayer # 0)
        };

        playSoundUI ["a3\sounds_f\sfx\blip1.wss"];

        private _acceptInvite = [
            localize "STR_SQUADS_joinSquadTitle",
            format [localize "STR_SQUADS_receiveInvitationText", _inviterName, _squad select 0],
            localize "STR_SQUADS_joinSquadAccept",
            localize "STR_SQUADS_joinSquadDecline"
        ] call WL2_fnc_prompt;

        missionNamespace setVariable ["SQD_playerHasInvite", false];

        if (_acceptInvite) then {
            ["add", [_inviter, getPlayerID player]] remoteExec ["SQD_fnc_server", 2];

            ["TaskJoinSquad"] call WLT_fnc_taskComplete;
        };
    };
    case "newjoin": {
        private _joinerId = _params select 0;
        private _joiner = _allPlayers select { getPlayerID _x == _joinerId };

        playSoundUI ["a3\animals_f_beta\sheep\data\sound\sheep3.wss"];

        if (count _joiner == 0) exitWith {
            _return = 1;
        };
        _joiner = _joiner # 0;

        if (_joiner == player) then {
            systemChat "You have joined a squad.";
        } else {
            systemChat format ["%1 has joined your squad.", name _joiner];
        };
    };
    case "promote": {
        private _selection = tvCurSel TREE;
        if (isNil "_selection") exitWith {
            _return = 1;
        };

        private _player = tvData [TREE, _selection];

        ctrlShow [PROMOTE_BUTTON, false];
        ctrlShow [KICK_BUTTON, false];

        ["promote", [_player]] remoteExec ["SQD_fnc_server", 2];
    };
    case "promoted": {
        systemChat "You have been promoted to squad leader.";

        private _sound = playSoundUI ["a3\music_f_tank\maintheme_f_tank.ogg", 1, 1, false, 1.7];
        sleep 2.8;
        stopSound _sound;
    };
    case "kick": {
        private _selection = tvCurSel TREE;
        if (isNil "_selection") exitWith {
            _return = 1;
        };

        private _player = tvData [TREE, _selection];

        ctrlShow [KICK_BUTTON, false];

        ["remove", [_player]] remoteExec ["SQD_fnc_server", 2];
    };
    case "isInMySquad": {
        // input: target player id
        private _target = _params select 0;

        if (_mySquadNumber == -1) then {
            _return = false;
        } else {
            _return = (((_squadManager select _mySquadNumber) select 2) find _target) > -1;
        };
    };
    case "isInSquad": {
        // input: target player id
        private _target = _params select 0;
        _return = _squadManager findIf {(_x select 2) find _target > -1} > -1;
    };
    case "getMySquadLeader": {
        private _playerId = getPlayerID player;

        private _squad = _squadManager select {(_x select 2) find _playerId > -1};
        if (count _squad == 0) exitWith {
            _return = "-1";
        };

        _squad = _squad # 0;
        private _squadLeaderID = _squad select 1;
        _message = format ["Squad Leader of %1: %2", _playerId, _squadLeaderID];
        _return = _squadLeaderID;
    };
    case "ftSquadLeader": {
        // call this async
        private _sl = ['getMySquadLeader'] call SQD_fnc_client;
        private _squadLeader = _allPlayers select {getPlayerID _x == _sl};
        if (count _squadLeader == 0) exitWith {
            _return = 1;
        };
        _squadLeader = _squadLeader # 0;

        [player, "fastTravelSquadLeader"] remoteExec ["WL2_fnc_handleClientRequest", 2];

        titleCut ["", "BLACK OUT", 1];
        openMap [false, false];

        sleep 1;

        private _tagAlong = (units player) select {
            (_x distance2D player <= 100) &&
            (isNull objectParent _x) &&
            alive _x &&
            _x != player &&
            _x getVariable ["BIS_WL_ownerAsset", "123"] == getPlayerUID player
        };

        private _squadPlayer = vehicle _squadLeader;
        if (_squadPlayer != _squadLeader && (_squadPlayer emptyPositions "Cargo" > 0)) then {
            player moveInCargo _squadPlayer;
            {
                _x moveInCargo _squadPlayer;
            } forEach _tagAlong;
        } else {
            private _destination = getPosATL _squadLeader;
            {
                _x setVehiclePosition [_destination, [], 5, "NONE"];
            } forEach _tagAlong;
            player setVehiclePosition [_destination, [], 5, "NONE"];
        };

        sleep 1;

        titleCut ["", "BLACK IN", 1];
    };
    case "ftSquad": {
        private _squadTarget = _params select 0;
        private _squadTargetPlayer = _allPlayers select {getPlayerID _x == _squadTarget} select 0;

        titleCut ["", "BLACK OUT", 1];
        openMap [false, false];

        sleep 1;

        private _tagAlong = (units player) select {
            (_x distance2D player <= 100) &&
            (isNull objectParent _x) &&
            alive _x &&
            _x != player &&
            _x getVariable ["BIS_WL_ownerAsset", "123"] == getPlayerUID player
        };

        private _squadPlayer = vehicle _squadTargetPlayer;
        if (_squadPlayer != _squadTargetPlayer && (_squadPlayer emptyPositions "Cargo" > 0)) then {
            player moveInCargo _squadPlayer;
            {
                _x moveInCargo _squadPlayer;
            } forEach _tagAlong;
        } else {
            private _destination = getPosATL _squadTargetPlayer;
            {
                _x setVehiclePosition [_destination, [], 5, "NONE"];
            } forEach _tagAlong;
            player setVehiclePosition [_destination, [], 5, "NONE"];
        };

        sleep 1;

        titleCut ["", "BLACK IN", 1];
    };
    case "rename": {
        if (isNull (findDisplay RENAME_WINDOW)) then {
            createDialog "SquadsMenu_Rename";
        };

        private _squad = _squadManager select _mySquadNumber;
        private _squadName = _squad select 0;
        ctrlSetText [RENAME_EDIT, _squadName];

        private _renamEditControl = displayCtrl RENAME_EDIT;
        ctrlSetFocus _renamEditControl;
        _renamEditControl ctrlSetTextSelection [0, count _squadName];

        _return = true;
    };
    case "renamed": {
        private _newName = ctrlText RENAME_EDIT;

        private _disallowList = getArray (missionConfigFile >> "adminFilter");
        private _findInDisallowList = _disallowList findIf { [_x, _newName] call BIS_fnc_inString };
        if (_findInDisallowList > -1) then {
            _newName = selectRandom ["AIRHEAD ARMADA", "BORING BATTALION", "CLOWN COMPANY", "DUMMY DETACHMENT"];
        };

        profileNamespace setVariable ["SQD_nameDefault", _newName];

        ["rename", [getPlayerID player, _newName]] remoteExec ["SQD_fnc_server", 2];
        (findDisplay RENAME_WINDOW) closeDisplay 1;
    };
    case "isRegularSquadMember": {
        // Check if player is regular squad member
        private _playerId = _params select 0;

        private _isRegular = _squadManager findIf { (_x select 2) find _playerId > -1 && (_x select 1) != _playerId } > -1;

        _message = format ["Player %1 is regular squad member: %2", _playerId, _isRegular];
        _return = _isRegular;
    };
    case "isSquadLeader": {
        // Check if player is squad leader
        private _playerId = _params select 0;

        private _sl = ['getMySquadLeader'] call SQD_fnc_client;
        private _squad = _squadManager select {(_x select 2) find _playerId > -1};
        if (count _squad == 0) exitWith {
            _return = false;
        };

        _squad = _squad # 0;
        private _squadLeaderID = _squad select 1;
        _return = (_squadLeaderID == _playerId);
    };
    case "isSquadLeaderOfSize": {
        // Check if player is squad leader of a squad of a certain size or greater
        private _playerId = _params select 0;
        private _size = _params select 1;

        private _squad = _squadManager select { (_x select 1) == _playerId };
        if (count _squad == 0) exitWith {
            _return = false;
        };

        _squad = _squad # 0;
        private _squadSize = count (_squad select 2);
        _return = _squadSize >= _size;
    };
    case "getSquadNameOfPlayer": {
        private _playerId = _params select 0;

        private _squad = _squadManager select { (_x select 2) find _playerId > -1 };
        if (count _squad == 0) exitWith {
            _return = "No Squad";
        };

        _squad = _squad # 0;
        _return = _squad select 0;
    };
    case "areInSquad": {
        private _player1 = _params select 0;
        private _player2 = _params select 1;

        if (_player1 == _player2) exitWith {
            _return = true;
        };

        private _squad = _squadManager select { (_x select 2) find _player1 > -1 };
        if (count _squad == 0) exitWith {
            _return = false;
        };

        _squad = _squad # 0;
        private _squadMembers = _squad select 2;
        _return = _squadMembers find _player2 > -1;
    };
    case "getAllInSquad": {
        private _playerId = getPlayerID player;
        private _squads = SQUAD_MANAGER select {(_x select 2) find _playerId > -1};
        if (count _squads == 0) then {
            _return = [];
        } else {
            private _squad = _squads select 0;
            private _squadmateIds = _squad select 2;
            private _squadmates = _allPlayers select {
                getPlayerID _x in _squadmateIds;
            };
            _return = _squadmates;
        };
    };
    case "showInSquadChat": {
        private _person = _params select 0;
        private _channel = _params select 1;

        private _voiceChannels = missionNamespace getVariable ["SQD_VoiceChannels", [-1, -1]];
        private _sideCustomChannel = if (side group _person == WEST) then {
            _voiceChannels # 0
        } else {
            _voiceChannels # 1
        };
        if (_channel != (_sideCustomChannel + 5)) exitWith {
            _return = true;
        };

        private _playerId = getPlayerID _person;
        private _isInMySquad = ["isInMySquad", [_playerId]] call SQD_fnc_client;
        _return = _isInMySquad;
    };
};

if (isNil "_return") exitWith {};

_return;