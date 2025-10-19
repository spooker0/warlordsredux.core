#include "includes.inc"
private _setLevel = {
	params ["_levelDisplay"];
	if (player getVariable ["WL_playerLevel", "Recruit"] == _levelDisplay) exitWith {};
	player setVariable ["WL_playerLevel", _levelDisplay, true];
};

private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];
private _hideMyIdentity = _settingsMap getOrDefault ["hideMyIdentity", true];

if (_hideMyIdentity) then {
	private _identityId = random [76561197960265728, 76561193665298432, 76561202255233023] toFixed 0;
	private _hiddenIdentity = player getVariable ["WL2_hideIdentity", ""];
	if (_hiddenIdentity == "") then {
		player setVariable ["WL2_hideIdentity", _identityId, true];
	};
};

private _uid = getPlayerUID player;
private _isAdmin = _uid in (getArray (missionConfigFile >> "adminIDs"));
if (_isAdmin) then {
	["Developer", true] call RWD_fnc_addBadge;
} else {
	["Developer", false, true] call RWD_fnc_addBadge;
};

private _isModerator = _uid in (getArray (missionConfigFile >> "moderatorIDs"));
if (_isModerator) then {
	["Moderator", true] call RWD_fnc_addBadge;
} else {
	["Moderator", false, true] call RWD_fnc_addBadge;
};

private _isSpectator = _uid in (getArray (missionConfigFile >> "spectatorIDs"));
if (_isSpectator) then {
	["Spectator", true] call RWD_fnc_addBadge;
} else {
	["Spectator", false, true] call RWD_fnc_addBadge;
};

private _currentBadge = player getVariable ["WL2_currentBadge", ""];
private _level = ["getLevel"] call WLC_fnc_getLevelInfo;
private _playerLevel = format ["Level %1 | %2", _level, _currentBadge];
[_playerLevel] call _setLevel;