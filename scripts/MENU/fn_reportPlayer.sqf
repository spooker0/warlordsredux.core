params ["_sender", "_targetUid", "_reason"];

if (isNull _sender) exitWith {};
if !(isServer) exitWith {};
if (remoteExecutedOwner != owner _sender) exitWith {};

private _targetPlayer = _targetUid call BIS_fnc_getUnitByUID;
if (isNull _targetPlayer) exitWith {};

if (_reason == "") then {
    _reason = "No reason given.";
};

private _senderName = [_sender, true] call BIS_fnc_getName;
[_senderName, _reason] remoteExec ["MENU_fnc_playerReported", _targetPlayer];