#include "includes.inc"
params ["_text", ["_timer", 5]];

if (_text == "") exitWith {};

private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];
systemChat _text;

private _hideNotificationInterface = _settingsMap getOrDefault ["hideNotificationInterface", false];
if (_hideNotificationInterface) exitWith {};

["", _text] spawn BIS_fnc_showSubtitle;