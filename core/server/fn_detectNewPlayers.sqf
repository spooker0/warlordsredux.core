#include "includes.inc"
if (!isServer) exitWith {};

private _previousAIMax = -1;
private _connectedPlayerIds = [];
private _pendingSetups = createHashMap;
private _connectionEvents = [];

missionNamespace setVariable ["WL2_readyList", []];
serverNamespace setVariable ["WL2_connectedPlayerIds", _connectedPlayerIds];
serverNamespace setVariable ["WL2_pendingPlayerSetups", _pendingSetups];
serverNamespace setVariable ["WL2_playerConnectionEvents", _connectionEvents];

addMissionEventHandler ["PlayerConnected", {
    params ["_id", "_uid", "_name", "_jip", "_owner", "_idStr"];
    if (_uid != "") then {
        private _connectionEvents = serverNamespace getVariable ["WL2_playerConnectionEvents", []];
        _connectionEvents pushBack [_idStr, true, _owner];
    };
}];

addMissionEventHandler ["PlayerDisconnected", {
    params ["_id", "_uid", "_name", "_jip", "_owner", "_idStr"];
    private _connectionEvents = serverNamespace getVariable ["WL2_playerConnectionEvents", []];
    _connectionEvents pushBack [_idStr, false, 0];
}];

private _nextReconcile = 0;
while { !BIS_WL_missionEnd } do {
    private _connectionChanges = [];
    if (serverTime >= _nextReconcile) then {
        private _userIds = [];
        private _completeSnapshot = true;
        {
            private _info = getUserInfo _x;
            if (count _info < 3) then {
                _completeSnapshot = false;
                continue;
            };
            _info params ["_playerId", "_owner", "_uid"];
            if (_uid == "") then {
                if (_owner > 2) then {
                    _completeSnapshot = false;
                };
                continue;
            };

            _userIds pushBackUnique _playerId;
            if !(_playerId in _connectedPlayerIds) then {
                _connectionChanges pushBack [_playerId, true, _owner];
            };
        } forEach allUsers;

        if (!isMultiplayer && hasInterface) then {
            private _playerId = getPlayerID player;
            if (!(_playerId in ["", "-1"]) && !(_playerId in _connectedPlayerIds)) then {
                _connectionChanges pushBack [_playerId, true, clientOwner];
            };
            _completeSnapshot = false;
        };

        if (_completeSnapshot) then {
            {
                _connectionChanges pushBack [_x, false, 0];
            } forEach (_connectedPlayerIds - _userIds);
        };
        _nextReconcile = serverTime + 30;
    };

    while { count _connectionEvents > 0 } do {
        _connectionChanges pushBack (_connectionEvents deleteAt 0);
    };

    {
        _x params ["_playerId", "_connected", "_owner"];
        if (_playerId in ["", "-1"]) then {
            continue;
        };
        if (_connected) then {
            if (_playerId in _connectedPlayerIds) then {
                continue;
            };
            _connectedPlayerIds pushBack _playerId;

            private _target = if (_owner >= 2) then { _owner } else { false };
            {
                missionNamespace setVariable [format ["%1_%2", _x, _playerId], nil, _target];
            } forEach ["WL2_sidePickerState", "WL2_playerEligibility", "WL2_playerSide", "WL2_playerSetupState"];
            _pendingSetups set [_playerId, serverTime];
        } else {
            private _index = _connectedPlayerIds find _playerId;
            if (_index != -1) then {
                _connectedPlayerIds deleteAt _index;
            };
            _pendingSetups deleteAt _playerId;
        };
    } forEach _connectionChanges;

    {
        if (count _connectionEvents > 0) then {
            break;
        };
        if (serverTime < _y) then {
            continue;
        };

        private _retryDelay = [_x] call WL2_fnc_setupNewPlayer;
        if (_retryDelay > 0) then {
            _pendingSetups set [_x, serverTime + _retryDelay];
        } else {
            _pendingSetups deleteAt _x;
        };
    } forEach +_pendingSetups;

    private _thresholds = [8, 15, 20, 30, 40];
    private _allPlayers = call BIS_fnc_listPlayers;
    private _activePlayers = _allPlayers select {
        private _isAfk = _x getVariable ["WL2_afk", false];
        !_isAfk
    };

    private _players = count _activePlayers;
    private _value = 1;
    {
        if (_players < _x) then {
            _value = _value + 1;
        };
    } forEach _thresholds;
    if (_value != _previousAIMax) then {
        missionNamespace setVariable ["WL2_maxSubordinates", _value, true];
    };
    _previousAIMax = _value;

    uiSleep 0.5;
};
