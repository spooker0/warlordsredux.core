private _setLevel = {
	params ["_levelDisplay"];
	if (player getVariable ["WL_playerLevel", "Recruit"] == _levelDisplay) exitWith {};
	player setVariable ["WL_playerLevel", _levelDisplay, true];
};

private _uid = getPlayerUID player;
private _isAdmin = _uid in (getArray (missionConfigFile >> "adminIDs"));
if (_isAdmin) exitWith {
	["Developer"] call _setLevel;
};

private _isModerator = _uid in (getArray (missionConfigFile >> "moderatorIDs"));
if (_isModerator) exitWith {
	["Moderator"] call _setLevel;
};

private _isSpectator = _uid in (getArray (missionConfigFile >> "spectatorIDs"));
if (_isSpectator) exitWith {
	["Spectator"] call _setLevel;
};

private _finalTutorialTasks = ["TaskDeleteVehicle", "TaskVehicleParadrop", "TaskRefuelVehicle", "TaskFastTravelSquad", "TaskSlingload"];
private _completionStatuses = profileNamespace getVariable ["WLT_TaskCompletionStatuses", createHashMap];
private _allDone = true;
{
	private _taskCompleted = _completionStatuses getOrDefault [_x, false];
	if (!_taskCompleted) then {
		_allDone = false;
	};
} forEach _finalTutorialTasks;

private _level = ["getLevel"] call WLC_fnc_getLevelInfo;
private _playerLevel = if (!_allDone && _level < 10) then {
	"Recruit"
} else {
	format ["Level %1", _level];
};

[_playerLevel] call _setLevel;