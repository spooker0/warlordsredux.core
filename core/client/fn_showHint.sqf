#include "includes.inc"
params ["_layer", ["_hintParams", []], ["_timeout", -1], ["_isAnimation", false]];

private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];
private _showHint = _settingsMap getOrDefault [format["showHint%1", _layer], true];

private _display = uiNamespace getVariable ["RscWLHintMenu", displayNull];
if (isNull _display) then {
    "hintLayer" cutRsc ["RscWLHintMenu", "PLAIN", -1, true, true];
    _display = uiNamespace getVariable "RscWLHintMenu";
};
private _texture = _display displayCtrl 5502;
// _texture ctrlWebBrowserAction ["OpenDevConsole"];

if (count _hintParams == 0) exitWith {
    uiNamespace setVariable [format ["WL2_cancelAnimation_%1", _layer], true];

    private _scriptClear = format [
        "clearHint(""%1"");",
        _layer
    ];
    _texture ctrlWebBrowserAction ["ExecJS", _scriptClear];
};

uiNamespace setVariable [format ["WL2_cancelAnimation_%1", _layer], false];

if (_showHint) then {
    private _hintTitle = _hintParams select 0;
    _hintTitle = _texture ctrlWebBrowserAction ["ToBase64", _hintTitle];

    private _hintArray = [];
    {
        private _actionName = _x select 0;
        private _actionKey = _x select 1;

        private _actionKeyText = (actionKeysNames _actionKey) regexReplace ["""", ""];
        _actionKeyText = toUpper _actionKeyText;
        if (_actionKeyText == "") then {
            _actionKeyText = _actionKey;
        };
        _hintArray pushBack [toUpper _actionName, _actionKeyText];
    } forEach (_hintParams select 1);

    private _hintText = toJSON _hintArray;
    _hintText = _texture ctrlWebBrowserAction ["ToBase64", _hintText];

    private _script = format [
        "updateHint(""%1"", atobr(""%2""), atobr(""%3""));",
        _layer,
        _hintTitle,
        _hintText
    ];
    _texture ctrlWebBrowserAction ["ExecJS", _script];
};

if (_timeout < 0) exitWith {};

private _startTime = serverTime;
while { serverTime - _startTime < _timeout && !isNull _texture } do {
    private _cancelAnimation = uiNamespace getVariable [format ["WL2_cancelAnimation_%1", _layer], false];
    if (_cancelAnimation) then {
        break;
    };
    uiSleep 0.05;
    if (_isAnimation) then {
        _texture ctrlWebBrowserAction ["ExecJS", format ["updateAnimationTimer(%1);", (serverTime - _startTime) / _timeout]];
    };
};

_texture ctrlWebBrowserAction ["ExecJS", format ["clearHint(""%1"");", _layer]];