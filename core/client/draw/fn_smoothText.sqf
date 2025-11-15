#include "includes.inc"
params ["_text", ["_timer", 5]];

if (_text == "") exitWith {};

private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];
private _announcerTextSize = _settingsMap getOrDefault ["announcerTextSize", 1];
private _announcerTime = _settingsMap getOrDefault ["announcerTime", 1];

private _display = uiNamespace getVariable ["RscWLHintMenu", displayNull];
if (isNull _display) then {
    "hintLayer" cutRsc ["RscWLHintMenu", "PLAIN", -1, true, true];
    _display = uiNamespace getVariable "RscWLHintMenu";
};
private _texture = _display displayCtrl 5502;
// _texture ctrlWebBrowserAction ["OpenDevConsole"];

private _notificationText = _texture ctrlWebBrowserAction ["ToBase64", _text];

private _script = format ["addNotification(atobr(""%1""), %2, %3);", _notificationText, _announcerTextSize, _timer * _announcerTime];
_texture ctrlWebBrowserAction ["ExecJS", _script];