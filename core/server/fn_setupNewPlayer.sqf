#include "includes.inc"
params ["_warlord"];

if (_warlord getVariable ["WL2_playerSetupStarted", false]) exitWith {};
_warlord setVariable ["WL2_playerSetupStarted", true];

private _initLog = {
    params ["_error"];
#if WL_DEBUG_INIT
    private _message = format ["[Warlord Init] %1", _error];
    diag_log _message;
    [_error] remoteExec ["diag_log", _warlord];
#endif
};

private _startTime = serverTime;
private _uid = "";

while { _uid == "" } do {
    if (serverTime - _startTime > 30) then {
        ["Cannot find player UID for over 30 seconds. Aborting."] call _initLog;
		break;
	};

	if (isNull _warlord) then {
        ["Cannot find player UID, warlord is null. Aborting."] call _initLog;
		break;
	};

    private _playerUid = _warlord getVariable ["BIS_WL_ownerAsset", ""];
	private _playerUid = getPlayerUID _warlord;
	if (!isNil "_playerUid" && {_playerUid != ""}) then {
		_uid = _playerUid;
	} else {
        [format ["Cannot find player UID for %1.", _warlord]] call _initLog;

        private _playerId = getPlayerID _warlord;
        private _playerUidFromId = _playerId getUserInfo 2;
        if (!isNil "_playerUidFromId" && {_playerUidFromId != ""}) then {
            _uid = _playerUidFromId;
        } else {
            [format ["Cannot find player UID from player ID %1.", _playerId]] call _initLog;
        };
	};

    uiSleep 1;
};

if (_uid == "") exitWith {
    ["Aborted player setup due to not finding player UID."] call _initLog;
};

private _playerFundsDB = serverNamespace getVariable "fundsDatabase";
if (isNil "_playerFundsDB") exitWith {
    ["Cannot find fundsDatabase. Aborting."] call _initLog;
};

private _playerList = serverNamespace getVariable "playerList";
if (isNil "_playerList") exitWith {
    ["Cannot find playerList. Aborting."] call _initLog;
};

[format ["Player UID found: %1", _uid]] call _initLog;

private _lockedToTeam = _playerList getOrDefault [_uid, civilian];
private _owner = owner _warlord;

_warlord setVariable ["BIS_WL_ownerAsset", _uid, true];
_warlord setVariable ["WL2_accessControl", 0, true];
[_warlord] remoteExec ["WL2_fnc_handleDamage", 0];

private _punishmentMap = missionNamespace getVariable ["WL2_punishmentMap", createHashMap];
private _punishIncident = _punishmentMap getOrDefault [_uid, []];

if (count _punishIncident > 0) then {
    [_punishIncident] remoteExec ["WL2_fnc_punishmentClient", _owner];
};

private _isAdmin = _uid in (getArray (missionConfigFile >> "adminIDs"));
private _isModerator = _uid in (getArray (missionConfigFile >> "moderatorIDs"));
private _isSpectator = _uid in (getArray (missionConfigFile >> "spectatorIDs"));

private _currentSide = side group _warlord;
private _isRightTeam = if (_isAdmin || _isModerator || _isSpectator) then { true } else {
    _lockedToTeam in [_currentSide, civilian];
};

["Starting lockouts."] call _initLog;

if (!_isRightTeam) exitWith {
    _warlord setVariable ["WL2_playerSetupState", "Teamlocked", _owner];
};

private _timeSinceStart = WL_DURATION_MISSION - (estimatedEndServerTime - serverTime);
private _exceedGracePeriod = _timeSinceStart > 60 * 5;
private _isImbalanced = if (_exceedGracePeriod) then {
    private _friendlyCount = playersNumber _currentSide;
    private _enemySide = if (_currentSide == west) then {
        east
    } else {
        west
    };
    private _enemyCount = playersNumber _enemySide;
    _friendlyCount - _enemyCount > 3;
} else {
    false
};
if (_isAdmin || _isModerator || _isSpectator) then {
    _isImbalanced = false;
};

if (_isImbalanced && _lockedToTeam == civilian) exitWith {
    _warlord setVariable ["WL2_playerSetupState", "Imbalance", _owner];
};

["Lockouts complete."] call _initLog;

_playerList set [_uid, _currentSide];

private _scoreboard = missionNamespace getVariable ["WL2_scoreboardData", createHashMap];
private _playerEntry = _scoreboard getOrDefault [_uid, createHashMap];
_scoreboard set [_uid, _playerEntry];
missionNamespace setVariable ["WL2_scoreboardData", _scoreboard];

["Scoreboard setup complete."] call _initLog;

["Imbalance calculations complete."] call _initLog;

private _readyList = missionNamespace getVariable ["WL2_readyList", []];
_readyList pushBackUnique _uid;

private _playerFunds = _playerFundsDB getOrDefault [_uid, -1];
if (_playerFunds == -1) then {
    [1000, _uid, false] call WL2_fnc_fundsDatabaseWrite;
};
[_playerFundsDB, _uid] call WL2_fnc_fundsDatabaseUpdate;

["Database writes complete."] call _initLog;

_warlord setVariable ["WL2_playerSetupState", "Complete", _owner];