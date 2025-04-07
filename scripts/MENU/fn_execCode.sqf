/*
	Author: Weasley Wells
	Description: Executes given code by client if their player UID is in the  description.ext
*/
params [["_sender", objNull , [objNull]], ["_code", "", [""]]];

if (isNull _sender) exitWith {};

private _serverCheck = isDedicated && remoteExecutedOwner == (owner _sender) && (remoteExecutedOwner + (owner _sender)) > 4;
private _adminIds = getArray (missionConfigFile >> "adminIDs");
private _adminCheck = if (isDedicated) then {
    private _remotePlayer = (allPlayers select { owner _x == remoteExecutedOwner }) # 0;
	(getPlayerUID _remotePlayer) in _adminIds;
} else {
	(getPlayerUID player) in _adminIds;
};

if ((_serverCheck && !isDedicated) || !_adminCheck) exitWith {
	if (isDedicated) then {
		diag_log format ["WLAC: Name: %1 UID: %2 Attempted to execute command {%3}", _sender, getPlayerUID _sender, _code];
	} else {
		[format ["WLAC: Name:%1 UID:%2 Attempted to execute command {%3}", player, getPlayerUID player, _code]] remoteExec ["diag_log", 2];
	};
};

if (_code == "") exitWith {};

private _compiledCode = compile _code;
private _return = call _compiledCode;
if (isNil {_return}) then {
    _return = "No return value";
};

if (isDedicated) then {
    _return = format ["Server (Uptime %1s): %2", serverTime, _return];
    [_return] remoteExec ["MENU_fnc_setReturnValue", remoteExecutedOwner];
} else {
    _return = format ["Local (Uptime %1s): %2", serverTime, _return];
    [_return] spawn MENU_fnc_setReturnValue;
};
