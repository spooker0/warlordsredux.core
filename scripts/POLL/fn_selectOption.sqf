params ["_optionIndex", "_player"];

if (!isServer) exitWith {};
if (owner _player != remoteExecutedOwner) exitWith {};

private _pollMap = missionNamespace getVariable ["POLL_PollResults", createHashMap];
_pollMap set [getPlayerUID _player, _optionIndex];
missionNamespace setVariable ["POLL_PollResults", _pollMap, true];