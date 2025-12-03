#include "includes.inc"
params ["_text", ["_timer", 5]];

if (_text == "") exitWith {};

private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];

private _hideNotificationInterface = _settingsMap getOrDefault ["hideNotificationInterface", false];
if (_hideNotificationInterface) exitWith {
    systemChat _text;
};

private _announcerTime = _settingsMap getOrDefault ["announcerTime", 1];

uiNamespace setVariable ["WL2_currentNotification", [_text, serverTime + _timer * _announcerTime]];