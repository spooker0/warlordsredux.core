#include "includes.inc"
params ["_layer", ["_hintParams", []], ["_timeout", -1], ["_isAnimation", false]];

private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];
private _showHint = _settingsMap getOrDefault [format["showHint%1", _layer], true];

private _display = uiNamespace getVariable ["RscWLProgressDisplay", displayNull];
if (isNull _display) then {
    "progress" cutRsc ["RscWLProgressDisplay", "PLAIN", -1, true, false];
    _display = uiNamespace getVariable "RscWLProgressDisplay";
};
private _bar = _display displayCtrl 5000;
private _text = _display displayCtrl 5001;
private _hintText = _display displayCtrl 5002;

if (count _hintParams == 0) exitWith {
    uiNamespace setVariable [format ["WL2_cancelAnimation_%1", _layer], true];
    _display closeDisplay 0;
};

uiNamespace setVariable [format ["WL2_cancelAnimation_%1", _layer], false];

if (_showHint) then {
    private _hintTitle = _hintParams select 0;
    private _hintKeys = _hintParams select 1;
    private _hintArray = [];
    {
        private _actionName = _x select 0;
        private _actionKey = _x select 1;

        private _actionKeyText = (actionKeysNames _actionKey) regexReplace ["""", ""];
        _actionKeyText = toUpper _actionKeyText;
        if (_actionKeyText == "") then {
            _actionKeyText = _actionKey;
        };
        _hintArray pushBack format ["<t align='left'>%1</t><t align='right' color='#00ff00'>[%2]</t>", toUpper _actionName, _actionKeyText];
    } forEach _hintKeys;

    _hintText ctrlSetStructuredText parseText format [
        "<t size='2' align='center'>&#160;<t size='1.2'>%1</t>&#160;</t><br/>%2",
        _hintTitle,
        _hintArray joinString "<br/>"
    ];
    _hintText ctrlSetPositionH (0.1 + 0.032 * (count _hintKeys));
    _hintText ctrlCommit 0;
} else {
    _hintText ctrlShow false;
};

_bar ctrlShow _isAnimation;
_text ctrlShow _isAnimation;

if (_timeout < 0) exitWith {};

private _startTime = serverTime;
while { serverTime - _startTime < _timeout && !isNull _bar } do {
    private _cancelAnimation = uiNamespace getVariable [format ["WL2_cancelAnimation_%1", _layer], false];
    if (_cancelAnimation) then {
        break;
    };
    uiSleep 0.05;
    if (_isAnimation) then {
        private _percent = (serverTime - _startTime) / _timeout;
        _bar progressSetPosition _percent;
        _text ctrlSetStructuredText parseText format ["<t align='center'>%1%%</t>", round (_percent * 100)];
    };
};

_display closeDisplay 0;