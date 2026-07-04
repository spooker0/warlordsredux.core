#include "includes.inc"
params ["_text", ["_isAdditionalSub", false]];

if (_text == "") exitWith {};

private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];
private _additionalSubs = _settingsMap getOrDefault ["additionalSubs", false];
if (_isAdditionalSub && !_additionalSubs) exitWith {};

systemChat _text;

private _display = uiNamespace getVariable ["RscWarlordsHUD", displayNull];
private _subtitlesControl = _display displayCtrl 2110;
if (isNull _subtitlesControl) exitWith {};

_subtitlesControl ctrlSetStructuredText parseText format [
    "<t align='center' shadow='2'>%1</t>",
    _text
];
_subtitlesControl ctrlShow true;
_subtitlesControl ctrlSetFade 0;
_subtitlesControl ctrlCommit 0;

_subtitlesControl setVariable ["WL2_subtitleFadeTime", time + 5];