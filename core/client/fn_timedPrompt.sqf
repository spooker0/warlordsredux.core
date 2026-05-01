#include "includes.inc"
params ["_modalType", "_modalText", "_confirmText", "_cancelText", "_callbackConfirm", "_callbackCancel", "_callbackParams", "_timeout", "_defaultTrue"];

private _queue = uiNamespace getVariable "WL2_timedPromptQueue";
if (isNil "_queue") exitWith {};

private _display = uiNamespace getVariable ["RscWLPromptDisplay", displayNull];

private _queueEntry = [_modalType, false];
_queue pushBack _queueEntry;

waitUntil {
    uiSleep 0.01;
    (_queue # 0) isEqualRef _queueEntry && isNull (uiNamespace getVariable ["RscWLPromptDisplay", displayNull]);
};

if (_queueEntry # 1) exitWith {
    _queue deleteAt 0;
    _callbackParams spawn _callbackCancel;
};

uiSleep 0.5;

"TimedPrompt" cutRsc ["RscWLPromptDisplay", "PLAIN", -1, true, true];
_display = uiNamespace getVariable ["RscWLPromptDisplay", displayNull];

playSoundUI ["a3\missions_f_oldman\data\sound\phone_sms\chime\phone_sms_chime_07.wss", 1];

private _titleControl = _display displayCtrl 41002;
private _displayText = format [
    "<t align='center' size='0.85'>%1</t><br/><br/><t align='left' color='#33ff33'>%2 (%3)</t><t align='right' color='#ff3333'>%4 (%5)</t>",
    _modalText,
    _confirmText, (actionKeysNames ["LeanLeft", 1, "Combo"]) regexReplace ["""", ""],
    _cancelText, (actionKeysNames ["LeanRight", 1, "Combo"]) regexReplace ["""", ""]
];
_titleControl ctrlSetStructuredText parseText _displayText;

private _progressControl = _display displayCtrl 41003;
private _progressColor = if (_defaultTrue) then { [0.18, 1, 0.18, 1] } else { [1, 0.18, 0.18, 1] };
_progressControl ctrlSetTextColor _progressColor;

private _startTime = serverTime;
private _doAction = _defaultTrue;
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
    _callbackParams spawn _callbackConfirm;
} else {
    _callbackParams spawn _callbackCancel;
};

"TimedPrompt" cutText ["", "PLAIN"];

_queue deleteAt 0;