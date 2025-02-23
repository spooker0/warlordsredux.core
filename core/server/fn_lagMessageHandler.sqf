params ["_sender"];
private _messageTemplate = "Server Script Collector";
private _message = [_messageTemplate] call WL2_fnc_scriptCollector;
[_message] remoteExec ["WL2_fnc_lagMessageDisplay", _sender];