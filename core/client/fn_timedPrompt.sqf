#include "includes.inc"
params ["_modalText", "_confirmText", "_cancelText", "_callback", "_timeout"];

private _display = uiNamespace getVariable ["RscWLPromptDisplay", displayNull];
if (!isNull _display) exitWith {};

"TimedPrompt" cutRsc ["RscWLPromptDisplay", "PLAIN", -1, true, true];
_display = uiNamespace getVariable ["RscWLPromptDisplay", displayNull];

private _titleControl = _display displayCtrl 41002;
private _displayText = format [
    "<t align='center' size='0.85'>%1</t><br/><br/><t align='left' color='#33ff33'>%2 (%3)</t><t align='right' color='#ff3333'>%4 (%5)</t>",
    _modalText,
    _confirmText, (actionKeysNames ["LeanLeft", 1, "Combo"]) regexReplace ["""", ""],
    _cancelText, (actionKeysNames ["LeanRight", 1, "Combo"]) regexReplace ["""", ""]
];
_titleControl ctrlSetStructuredText parseText _displayText;

private _progressControl = _display displayCtrl 41003;

private _startTime = serverTime;
private _doAction = true;
while { serverTime < _startTime + _timeout } do {
    if (inputAction "LeanLeft" > 0) then {
        _doAction = true;
        break;
    };
    if (inputAction "LeanRight" > 0) then {
        _doAction = false;
        break;
    };

    private _timeFraction = (serverTime - _startTime) / _timeout;
    _progressControl progressSetPosition _timeFraction;
    uiSleep 0.001;
};
if (_doAction) then {
    call _callback;
} else {
    playSoundUI ["AddItemFailed"];
};

"TimedPrompt" cutText ["", "PLAIN"];