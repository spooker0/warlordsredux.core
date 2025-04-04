private _finalTutorialTasks = ["TaskDeleteVehicle", "TaskVehicleParadrop", "TaskRefuelVehicle", "TaskFastTravelSquad", "TaskSlingload"];
private _completionStatuses = profileNamespace getVariable ["WLT_TaskCompletionStatuses", createHashMap];
private _allDone = true;
{
	private _taskCompleted = _completionStatuses getOrDefault [_x, false];
	if (!_taskCompleted) then {
		_allDone = false;
	};
} forEach _finalTutorialTasks;

private _uid = getPlayerUID player;
private _isAdmin = _uid in (getArray (missionConfigFile >> "adminIDs"));
private _isPollster = _uid in (getArray (missionConfigFile >> "pollstersIDs"));
private _isDev = _isAdmin || _isPollster;

private _levelDisplay = if (_isDev) then {
	"Developer"
} else {
	private _playerLevel = ["getLevel"] call WLC_fnc_getLevelInfo;
	if (!_allDone && _playerLevel < 10) then {
		"Recruit"
	} else {
		format ["Level %1", _playerLevel];
	};
};

if (player getVariable ["WL_playerLevel", "Recruit"] == _levelDisplay) exitWith {};
player setVariable ["WL_playerLevel", _levelDisplay, true];