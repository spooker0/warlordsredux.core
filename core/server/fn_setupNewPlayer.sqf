params ["_warlord"];

if (_warlord getVariable ["WL2_playerSetupStarted", false]) exitWith {};
_warlord setVariable ["WL2_playerSetupStarted", true];

private _initLog = {
    params ["_error"];
    private _message = format ["[Server Init Error] %1", _error];
    diag_log _message;
    [_error] remoteExec ["diag_log", _warlord];
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

private _teamBlockVar = format ["WL2_teamBlocked_%1", _uid];
private _balanceBlockVar = format ["WL2_balanceBlocked_%1", _uid];
private _friendlyFireVar = format ["WL2_friendlyFire_%1", _uid];
private _punishVar = format ["WL2_punish_%1", _uid];

private _lockedToTeam = _playerList getOrDefault [_uid, sideUnknown];
private _currentSide = side group _warlord;
private _owner = owner _warlord;

_warlord setVariable ["BIS_WL_ownerAsset", _uid, true];
_warlord setVariable ["WL2_accessControl", 0, true];
[_warlord] call WL2_fnc_lastHitHandler;

if (_lockedToTeam != sideUnknown) then {
    private _correctSide = _lockedToTeam == _currentSide;
    missionNamespace setVariable [_teamBlockVar, !_correctSide, _owner];
	missionNamespace setVariable [_balanceBlockVar, false, _owner];

    if (_correctSide) then {
        private _friendlyFireIncidents = serverNamespace getVariable [_friendlyFireVar, []];
        [_friendlyFireIncidents] remoteExec ["WL2_fnc_friendlyFireHandleClient", _owner];
        private _punishIncident = serverNamespace getVariable [_punishVar, []];
        [_punishIncident] remoteExec ["WL2_fnc_punishmentClient", _owner];
    };
} else {
    private _exceedGracePeriod = (missionNamespace getVariable ["gameStart", 0]) + 300 < serverTime;
    private _isImbalanced = if (_exceedGracePeriod) then {
        private _friendlyCount = playersNumber _currentSide;
        private _enemySide = if (_currentSide == west) then {
            east
        } else {
            west
        };
        private _enemyCount = playersNumber _enemySide;

        (_friendlyCount - _enemyCount) > 3;
    } else {
        false;
    };

    if (!_isImbalanced) then {
        _playerList set [_uid, _currentSide];
    };

    missionNamespace setVariable [_teamBlockVar, false, _owner];
    missionNamespace setVariable [_balanceBlockVar, _isImbalanced, _owner];
};

call WL2_fnc_calcImbalance;

private _readyList = missionNamespace getVariable ["WL2_readyList", []];
_readyList pushBackUnique _uid;

private _playerFunds = _playerFundsDB getOrDefault [_uid, -1];
if (_playerFunds == -1) then {
    [1000, _uid] call WL2_fnc_fundsDatabaseWrite;
};
[_playerFundsDB, _uid] call WL2_fnc_fundsDatabaseUpdate;