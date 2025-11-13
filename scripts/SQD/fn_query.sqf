#include "includes.inc"
params ["_action", "_params"];

private _allPlayers = call BIS_fnc_listPlayers;
private _squadManager = missionNamespace getVariable ["SQUAD_MANAGER", []];

if (_action == "getPlayerForID") exitWith {
    private _playerId = _params select 0;

    private _player = _allPlayers select {
        getPlayerID _x == _playerId
    };
    if (count _player == 0) then {
        objNull;
    } else {
        _player select 0;
    };
};

if (_action == "getSquadForPlayer") exitWith {
    private _playerId = _params select 0;

    private _squads = ["getSquadsForPlayer", [_playerId]] call SQD_fnc_query;
    if (count _squads == 0) then {
        createHashMap;
    } else {
        _squads select 0;
    };
};

// Should only be used for clean up for error state
if (_action == "getSquadsForPlayer") exitWith {
    private _playerId = _params select 0;

    private _squads = _squadManager select {
        private _members = _x getOrDefault ["members", []];
        _playerId in _members
    };
    _squads;
};

if (_action == "getSquadmates") exitWith {
    // Get squadmates of player
    private _playerId = _params select 0;
    private _includeSelf = _params select 1;

    private _squad = ["getSquadForPlayer", [_playerId]] call SQD_fnc_query;
    if (count _squad == 0) exitWith { [] }; // player not in any squad

    private _squadMembers = _squad getOrDefault ["members", []];
    if (!_includeSelf) then {
        _squadMembers = _squadMembers select { _x != _playerId };
    };
    _squadMembers apply {
        ["getPlayerForID", [_x]] call SQD_fnc_query;
    };
};

if (_action == "isSquadLeader") exitWith {
    // Check if player is squad leader
    private _playerId = _params select 0;

    private _squad = ["getSquadForPlayer", [_playerId]] call SQD_fnc_query;
    if (count _squad == 0) exitWith { false }; // player not in any squad

    private _squadLeader = _squad getOrDefault ["leader", ""];
    _squadLeader == _playerId;
};

if (_action == "isSquadLeaderOfSize") exitWith {
    // Check if player is squad leader of squad of at least size
    private _playerId = _params select 0;
    private _size = _params select 1;

    private _squad = ["getSquadForPlayer", [_playerId]] call SQD_fnc_query;
    if (count _squad == 0) exitWith { false }; // player not in any squad

    private _squadLeader = _squad getOrDefault ["leader", ""];
    private _squadMembers = _squad getOrDefault ["members", []];
    (_squadLeader == _playerId) && (count _squadMembers >= _size);
};

if (_action == "getSquadLeaderForPlayer") exitWith {
    // Get squad leader of player
    private _playerId = _params select 0;

    private _squad = ["getSquadForPlayer", [_playerId]] call SQD_fnc_query;
    if (count _squad == 0) exitWith { objNull }; // player not in any squad

    private _squadLeaderId = _squad getOrDefault ["leader", ""];
    ["getPlayerForID", [_squadLeaderId]] call SQD_fnc_query;
};

if (_action == "isInASquad") exitWith {
    // Check if player is in squad
    private _playerId = _params select 0;

    private _squads = ["getSquadsForPlayer", [_playerId]] call SQD_fnc_query;
    count _squads > 0;
};

if (_action == "areInSquad") exitWith {
    // Check if two players are in the same squad
    private _playerId1 = _params select 0;
    private _playerId2 = _params select 1;

    private _squad1 = ["getSquadForPlayer", [_playerId1]] call SQD_fnc_query;
    _playerId2 in (_squad1 getOrDefault ["members", []]);
};

if (_action == "isRegularSquadMember") exitWith {
    // Check if player is regular squad member
    private _playerId = _params select 0;

    private _isInASquad = ["isInASquad", [_playerId]] call SQD_fnc_query;
    private _isSquadLeader = ["isSquadLeader", [_playerId]] call SQD_fnc_query;

    _isInASquad && !_isSquadLeader;
};

if (_action == "getSquadVotingPower") exitWith {
    // Get squad voting power of squad leader
    private _playerId = _params select 0;

    WL_PlayerSquadContribution = missionNamespace getVariable ["WL_PlayerSquadContribution", createHashMap];
    private _squad = ["getSquadForPlayer", [_playerId]] call SQD_fnc_query;
    if (count _squad == 0) exitWith {
        private _playerUid = _playerId getUserInfo 2;
        private _points = WL_PlayerSquadContribution getOrDefault [_playerUid, 0];
        _points max 1;
    };

    private _squadMembers = _squad getOrDefault ["members", []];
    private _votingPower = 0;
    {
        private _memberUid = _x getUserInfo 2;
        private _memberContribution = WL_PlayerSquadContribution getOrDefault [_memberUid, 0];
        _votingPower = _votingPower + (_memberContribution max 1);
    } forEach _squadMembers;

    _votingPower;
};

if (_action == "getCreatedFreeChannel") exitWith {
    private _foundChannel = 0;
    for "_i" from 1 to 10 do {
        private _channelInfo = radioChannelInfo _i;
        private _channelExists = _channelInfo # 5;
        if (_channelExists) then {
            private _squadsUsingChannel = _squadManager select {
                private _channelId = _x getOrDefault ["channel", 0];
                _channelId == _i;
            };
            if (count _squadsUsingChannel == 0) then {
                _foundChannel = _i;
                break;
            };
        };
    };
    _foundChannel;
};