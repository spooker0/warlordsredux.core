#include "includes.inc"
params ["_action", "_params"];

private _allPlayers = call BIS_fnc_listPlayers;

private _squadManager = missionNamespace getVariable ["SQUAD_MANAGER", []];

if (_action == "create") exitWith {
    private _squadName = profileNamespace getVariable ["SQD_nameDefault", format ["%1 SQUAD", toUpper (name player)]];
    private _leader = getPlayerID player;
    private _side = BIS_WL_playerSide;

    ["create", [_squadName, _leader, _side]] remoteExec ["SQD_fnc_server", 2];
};

if (_action == "leave") exitWith {
    ["remove", [getPlayerID player]] remoteExec ["SQD_fnc_server", 2];
};

if (_action == "invite") exitWith {
    private _invitee = _params select 0;

    private _inviter = getPlayerID player;

    ["invite", [_invitee, _inviter]] remoteExec ["SQD_fnc_server", 2];

    private _inviteePlayer = ["getPlayerForID", [_invitee]] call SQD_fnc_query;
    if (isNull _inviteePlayer) exitWith {};

    private _inviteeName = name _inviteePlayer;

    [format [localize "STR_SQUADS_sendInvitationSuccessText", _inviteeName]] call WL2_fnc_smoothText;
    playSoundUI ["a3\ui_f\data\sound\cfgnotifications\tasksucceeded.wss"];
};

if (_action == "invited") exitWith {
    // input: inviter id
    private _inviter = _params select 0;

    if (WL_IsSpectator) exitWith {};

    private _squadHasInvite = missionNamespace getVariable ["SQD_playerHasInvite", false];
    if (_squadHasInvite) exitWith {};
    missionNamespace setVariable ["SQD_playerHasInvite", true];

    private _squad = ["getSquadForPlayer", [_inviter]] call SQD_fnc_query;
    if (count _squad == 0) exitWith {}; // no squad found

    private _inviterPlayer = ["getPlayerForID", [_inviter]] call SQD_fnc_query;
    private _inviterName = if (isNull _inviterPlayer) then {
        "???"
    } else {
        name _inviterPlayer
    };

    playSoundUI ["a3\sounds_f\sfx\blip1.wss"];

    private _acceptInvite = [
        localize "STR_SQUADS_joinSquadTitle",
        format [localize "STR_SQUADS_receiveInvitationText", _inviterName, _squad getOrDefault ["name", ""]],
        localize "STR_SQUADS_joinSquadAccept",
        localize "STR_SQUADS_joinSquadDecline"
    ] call WL2_fnc_prompt;

    missionNamespace setVariable ["SQD_playerHasInvite", false];

    if (_acceptInvite) then {
        ["add", [_inviter, getPlayerID player]] remoteExec ["SQD_fnc_server", 2];
    };
};

if (_action == "newjoin") exitWith {
    private _joinerId = _params select 0;
    private _joiner = ["getPlayerForID", [_joinerId]] call SQD_fnc_query;

    playSoundUI ["a3\animals_f_beta\sheep\data\sound\sheep3.wss"];

    if (isNull _joiner) exitWith {};
    if (_joiner == player) then {
        ["You have joined a squad."] call WL2_fnc_smoothText;
    } else {
        [format ["%1 has joined your squad.", name _joiner]] call WL2_fnc_smoothText;
    };
};

if (_action == "promote") exitWith {
    private _player = _params select 0;
    ["promote", [_player]] remoteExec ["SQD_fnc_server", 2];
};

if (_action == "promoted") exitWith {
    ["You have been promoted to squad leader."] call WL2_fnc_smoothText;

    private _sound = playSoundUI ["a3\music_f_tank\maintheme_f_tank.ogg", 1, 1, false, 1.7];
    uiSleep 2.8;
    stopSound _sound;
};

if (_action == "kick") exitWith {
    private _player = _params select 0;
    ["remove", [_player]] remoteExec ["SQD_fnc_server", 2];
};

private _ftAction = {
    params ["_targetPlayer"];
    if (WL_ISDOWN(player)) exitWith {};

    if (WL_ISDOWN(_targetPlayer)) exitWith {
        ["Squad fast travel target is not valid."] call WL2_fnc_smoothText;
    };

    titleCut ["", "BLACK OUT", 1];
    openMap [false, false];

    uiSleep 1;

    if (WL_ISDOWN(_targetPlayer)) exitWith {
        ["Squad fast travel target is no longer valid."] call WL2_fnc_smoothText;
        titleCut ["", "BLACK IN", 1];
    };

    private _tagAlong = (units player) select {
        isNull objectParent _x
    } select {
        alive _x
    } select {
        _x != player
    } select {
        _x distance player < 200
    } select {
        _x getVariable ["BIS_WL_ownerAsset", "123"] == getPlayerUID player
    };
    _tagAlong pushBack player;

    {
        if (vehicle _targetPlayer != _targetPlayer) then {
            private _moveSuccess = _x moveInAny (vehicle _targetPlayer);
            if (_moveSuccess) then {
                continue;
            };
        };

        private _destination = _targetPlayer modelToWorld [0, 0, 0];
        _x setVehiclePosition [_destination, [], 5, "NONE"];
    } forEach _tagAlong;

    uiSleep 1;

    titleCut ["", "BLACK IN", 1];
};

if (_action == "ftSquadLeader") exitWith {
    // call this async
    [player, "fastTravelSquadLeader"] remoteExec ["WL2_fnc_handleClientRequest", 2];

    private _squadLeader = ["getSquadLeaderForPlayer", [getPlayerID player]] call SQD_fnc_query;
    [_squadLeader] call _ftAction;
};

if (_action == "ftSquad") exitWith {
    private _squadTargetId = _params select 0;
    private _squadTarget = ["getPlayerForID", [_squadTargetId]] call SQD_fnc_query;

    [_squadTarget] call _ftAction;
};

if (_action == "renamed") exitWith {
    private _newName = _params select 0;

    private _disallowList = getArray (missionConfigFile >> "adminFilter");
    private _findInDisallowList = _disallowList findIf { [_x, _newName] call BIS_fnc_inString };
    if (_findInDisallowList > -1) then {
        _newName = format ["%1 SQUAD", toUpper (name player)];
    };

    profileNamespace setVariable ["SQD_nameDefault", _newName];

    ["rename", [getPlayerID player, _newName]] remoteExec ["SQD_fnc_server", 2];
};