#include "includes.inc"
private _setLevel = {
	params ["_levelDisplay"];
	if (player getVariable ["WL_playerLevel", "Recruit"] == _levelDisplay) exitWith {};
	player setVariable ["WL_playerLevel", _levelDisplay, true];
};

private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];
private _showModStatus = _settingsMap getOrDefault ["showModStatus", true];

private _uid = getPlayerUID player;
private _isAdmin = _uid in (getArray (missionConfigFile >> "adminIDs"));
if (_isAdmin && _showModStatus) exitWith {
	["Developer"] call _setLevel;
};

private _isModerator = _uid in (getArray (missionConfigFile >> "moderatorIDs"));
if (_isModerator && _showModStatus) exitWith {
	["Moderator"] call _setLevel;
};

private _isSpectator = _uid in (getArray (missionConfigFile >> "spectatorIDs"));
if (_isSpectator && _showModStatus) exitWith {
	["Spectator"] call _setLevel;
};

private _currentBadge = player getVariable ["WL2_currentBadge", ""];
private _level = ["getLevel"] call WLC_fnc_getLevelInfo;
private _playerLevel = format ["Level %1 | %2", _level, _currentBadge];
[_playerLevel] call _setLevel;