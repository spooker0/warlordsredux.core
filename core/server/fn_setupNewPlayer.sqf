#include "includes.inc"
params ["_playerId"];
if (!isServer) exitWith { 0 };

private _connectedPlayerIds = serverNamespace getVariable ["WL2_connectedPlayerIds", []];
if !(_playerId in _connectedPlayerIds) exitWith { 0 };

private _playerFundsDB = serverNamespace getVariable "fundsDatabase";
private _playerList = serverNamespace getVariable "playerList";
if (isNil "_playerFundsDB" || isNil "_playerList") exitWith { 3 };

private _allPlayers = call BIS_fnc_listPlayers;
private _players = _allPlayers select {
    alive _x
} select {
    getPlayerID _x == _playerId
} select {
    private _owner = owner _x;
    _owner > 2 || (!isDedicated && _owner == 2)
};
if (count _players == 0) exitWith { 2 };

private _warlord = _players # 0;
private _owner = owner _warlord;
private _uid = getPlayerUID _warlord;
if (_uid == "") exitWith { 2 };

private _sidePickerStateVar = format ["WL2_sidePickerState_%1", _playerId];
private _eligibilityVar = format ["WL2_playerEligibility_%1", _playerId];
private _playerSideVar = format ["WL2_playerSide_%1", _playerId];
private _setupStateVar = format ["WL2_playerSetupState_%1", _playerId];

private _setupObject = _warlord getVariable ["WL2_playerSetupObject", objNull];
if (_setupObject isNotEqualTo _warlord) then {
    _warlord setVariable ["WL2_playerSetupObject", _warlord];
    _warlord setVariable ["BIS_WL_ownerAsset", _uid, true];
    _warlord setVariable ["WL2_accessControl", 0, true];
    [_warlord] remoteExec ["WL2_fnc_handleDamage", 0];

    private _ratings = profileNamespace getVariable ["WL2_playerRatings", createHashMap];
    _warlord setVariable ["WL2_playerRating", _ratings getOrDefault [_uid, WL_RATING_STARTER], true];
};

private _isAdmin = _uid in (getArray (missionConfigFile >> "adminIDs"));
private _isModerator = _uid in (getArray (missionConfigFile >> "moderatorIDs"));
private _isSpectator = _uid in (getArray (missionConfigFile >> "spectatorIDs"));
private _skipTeamChecks = _isAdmin || _isModerator || _isSpectator;
private _sidePickerState = missionNamespace getVariable [_sidePickerStateVar, civilian];
if (_sidePickerState == civilian) then {
    private _lockedToTeam = if (_skipTeamChecks) then { civilian } else {
        _playerList getOrDefault [_uid, civilian]
    };
    _sidePickerState = if (_lockedToTeam in [west, east]) then { _lockedToTeam } else { independent };

    private _punishmentMap = missionNamespace getVariable ["WL2_punishmentMap", createHashMap];
    private _punishIncident = _punishmentMap getOrDefault [_uid, []];
    if (count _punishIncident > 0) then {
        [_punishIncident] remoteExec ["WL2_fnc_punishmentClient", _owner];
    };
    missionNamespace setVariable [_sidePickerStateVar, _sidePickerState, [2, _owner]];
};

private _selectedSide = missionNamespace getVariable [_playerSideVar, independent];
private _currentSide = if (_sidePickerState in [west, east]) then { _sidePickerState } else { _selectedSide };
if !(_currentSide in [west, east]) exitWith {
    private _teamEligibility = [_warlord, _uid] call WL2_fnc_calcTeamEligibility;
    if (_skipTeamChecks) then {
        _teamEligibility set [0, [west, east]];
    };
    private _existingEligibility = missionNamespace getVariable [_eligibilityVar, []];
    if (_existingEligibility isNotEqualTo _teamEligibility) then {
        missionNamespace setVariable [_eligibilityVar, _teamEligibility, [2, _owner]];
    };
    0.5
};

private _oldGroup = group _warlord;
if (isNull _oldGroup || side _oldGroup != _currentSide) then {
    private _newGroup = createGroup [_currentSide, true];
    if (!isNull _newGroup) then {
        [_warlord] joinSilent _newGroup;
        if (local _oldGroup && count units _oldGroup == 0) then {
            deleteGroup _oldGroup;
        };
    };
};

_playerList set [_uid, _currentSide];
private _scoreboard = missionNamespace getVariable ["WL2_scoreboardData", createHashMap];
private _playerEntry = _scoreboard getOrDefault [_uid, createHashMap];
_scoreboard set [_uid, _playerEntry];
missionNamespace setVariable ["WL2_scoreboardData", _scoreboard];

private _readyList = missionNamespace getVariable ["WL2_readyList", []];
_readyList pushBackUnique _uid;
if !(_uid in _playerFundsDB) then {
    [1000, _uid, false, "Setup"] call WL2_fnc_fundsDatabaseWrite;
};

missionNamespace setVariable [_setupStateVar, "Complete", [2, _owner]];

#if WL_DEBUG_INIT
diag_log format ["[Warlord Init] %1: Setup complete.", _playerId];
#endif

0;