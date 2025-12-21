#include "includes.inc"
params ["_action", "_params"];

private _allPlayers = call BIS_fnc_listPlayers;

private _squadManager = missionNamespace getVariable ["SQUAD_MANAGER", []];
private _oldSquadManager = +_squadManager;

private _propagateChanges = {
    if (_squadManager isNotEqualTo _oldSquadManager) then {
        missionNamespace setVariable ["SQUAD_MANAGER", _squadManager, true];
    };
};

if (_action == "create") exitWith {
    // Create squad with name & leader
    private _squadName = _params select 0;
    private _leader = _params select 1;
    private _side = _params select 2;

    private _freeChannel = ["getCreatedFreeChannel", []] call SQD_fnc_query;
    private _customChannelId = if (_freeChannel > 0) then {
        _freeChannel
    } else {
        radioChannelCreate [[0.56, 0.93, 0.56, 1], _squadName, "%UNIT_NAME", []];
    };

    private _newSquad = createHashMapFromArray [
        ["name", _squadName],
        ["leader", _leader],
        ["members", [_leader]],
        ["side", _side],
        ["channel", _customChannelId]
    ];
    _squadManager pushBack _newSquad;
    call _propagateChanges;

    if (_customChannelId != 0) then {
        private _leaderPlayer = ["getPlayerForID", [_leader]] call SQD_fnc_query;
        _customChannelId radioChannelAdd [_leaderPlayer];
    };
};

if (_action == "invite") exitWith {
    // Invite player to squad
    private _playerId = _params select 0;
    private _inviter = _params select 1;

    private _squad = ["getSquadForPlayer", [_inviter]] call SQD_fnc_query;
    if (count _squad == 0) exitWith {}; // inviter not in a squad

    private _inviteeSquad = ["getSquadForPlayer", [_playerId]] call SQD_fnc_query;
    if (count _inviteeSquad > 0) exitWith {};   // player is already in a squad

    private _squadLeader = _squad getOrDefault ["leader", ""];
    private _inviteePlayer = ["getPlayerForID", [_playerId]] call SQD_fnc_query;
    if (_squadLeader != _inviter) then {
        private _inviterPlayer = ["getPlayerForID", [_inviter]] call SQD_fnc_query;

        if !(isNull _inviterPlayer || isNull _inviteePlayer) then {
            private _message = format ["%1 has invited %2 to the squad.", name _inviterPlayer, name _inviteePlayer];

            private _squadLeaderInfo = _squadLeader getUserInfo 1;
            if (!isNil "_squadLeaderInfo") then {
                [_message] remoteExec ["WL2_fnc_smoothText", _squadLeaderInfo # 1];
            };
        };
    };

    ["invited", [_inviter]] remoteExec ["SQD_fnc_client", _inviteePlayer];
};

if (_action == "add") exitWith {
    // Player join squad
    private _inviter = _params select 0;
    private _playerId = _params select 1;

    ["remove", [_playerId]] call SQD_fnc_server;

    private _squad = ["getSquadForPlayer", [_inviter]] call SQD_fnc_query;
    if (count _squad == 0) exitWith {}; // inviter not in a squad

    private _playersInSquad = _squad getOrDefault ["members", []];
    private _squadSize = count _playersInSquad;
    if (_squadSize >= SQD_MAX_SQUAD_SIZE) exitWith {
        private _message = format ["Squad ""%1"" is full: %2/%3", _squad getOrDefault ["name", ""], _squadSize, SQD_MAX_SQUAD_SIZE];
        [_message] remoteExec ["WL2_fnc_smoothText", remoteExecutedOwner];
    };

    _playersInSquad pushBackUnique _playerId;
    _squad set ["members", _playersInSquad];
    call _propagateChanges;

    private _newPlayer = ["getPlayerForID", [_playerId]] call SQD_fnc_query;
    private _squadChannelId = _squad getOrDefault ["channel", 0];
    if (_squadChannelId != 0) then {
        _squadChannelId radioChannelAdd [_newPlayer];
    };

    private _targets = _allPlayers select { getPlayerID _x in _playersInSquad };
    ["newjoin", [_playerId]] remoteExec ["SQD_fnc_client", _targets];
};

if (_action == "remove") exitWith {
    // Remove player from squad
    private _playerId = _params select 0;

    private _squads = ["getSquadsForPlayer", [_playerId]] call SQD_fnc_query;
    private _player = ["getPlayerForID", [_playerId]] call SQD_fnc_query;

    {
        private _squad = _x;

        private _members = _squad getOrDefault ["members", []];
        _members = _members select { _x != _playerId };
        _squad set ["members", _members];

        private _channel = _squad getOrDefault ["channel", 0];
        if (_channel != 0) then {
            _channel radioChannelRemove [_player];
        };

        if (_playerId == (_squad getOrDefault ["leader", ""])) then {
            if (count _members > 0) then {
                private _playerContribution = missionNamespace getVariable ["WL_PlayerSquadContribution", createHashMap];
                private _sortedMembers = [_members, [_playerContribution], {
                    private _playerUid = _x getUserInfo 2;
                    _input0 getOrDefault [_playerUid, 0];
                }, "DESCEND"] call BIS_fnc_sortBy;

                private _newSquadLeader = _sortedMembers select 0;
                _squad set ["leader", _newSquadLeader];

                private _newSquadLeaderPlayer = ["getPlayerForID", [_newSquadLeader]] call SQD_fnc_query;
                ["promoted", []] remoteExec ["SQD_fnc_client", _newSquadLeaderPlayer];
            };
        };
    } forEach _squads;

    _squadManager = _squadManager select {
        count (_x getOrDefault ["members", []]) > 0
    };

    call _propagateChanges;
};

if (_action == "promote") exitWith {
    // Promote player to squad leader
    private _playerId = _params select 0;

    private _squad = ["getSquadForPlayer", [_playerId]] call SQD_fnc_query;
    if (count _squad == 0) exitWith {}; // player not in any squad

    _squad set ["leader", _playerId];
    call _propagateChanges;

    private _player = ["getPlayerForID", [_playerId]] call SQD_fnc_query;
    ["promoted", []] remoteExec ["SQD_fnc_client", _player];
};

if (_action == "rename") exitWith {
    // Rename squad
    private _playerId = _params select 0;
    private _newName = _params select 1;

    private _squad = ["getSquadForPlayer", [_playerId]] call SQD_fnc_query;
    if (count _squad == 0) exitWith {}; // player not in any squad

    _squad set ["name", _newName];
    call _propagateChanges;
};

if (_action == "earnPoints") exitWith {
    // Earn squad contribution points
    private _playerId = _params select 0;
    private _points = _params select 1;

    WL_PlayerSquadContribution = missionNamespace getVariable ["WL_PlayerSquadContribution", createHashMap];

    _oldPoints = WL_PlayerSquadContribution getOrDefault [_playerId, 0];
    _points = _points + _oldPoints;
    WL_PlayerSquadContribution set [_playerId, _points];

    missionNamespace setVariable ["WL_PlayerSquadContribution", WL_PlayerSquadContribution, true];
};

if (_action == "cleanUp") exitWith {
    private _allPlayerIds = _allPlayers apply { getPlayerID _x };

    {
        private _squad = _x;
        private _members = _squad getOrDefault ["members", []];
        {
            private _member = _x;
            private _danglingSquadmate = !(_member in _allPlayerIds);

            if (_danglingSquadmate) then {
                ["remove", [_member]] call SQD_fnc_server;
            };
        } forEach _members;
    } forEach _squadManager;

    _squadManager = _squadManager select {
        count (_x getOrDefault ["members", []]) > 0
    };

    call _propagateChanges;
};