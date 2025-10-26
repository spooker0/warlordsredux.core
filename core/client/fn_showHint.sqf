#include "includes.inc"
params ["_layer", ["_hintParams", []], ["_timeout", -1]];

private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];
private _showHint = _settingsMap getOrDefault [format["showHint%1", _layer], true];

if (!_showHint) exitWith {
    _layer cutText ["", "PLAIN"];
};

_layer = format ["hint%1", _layer];

private _display = uiNamespace getVariable ["RscWLHintMenu", displayNull];
if (count _hintParams < 2) exitWith {
    _layer cutText ["", "PLAIN"];
};

_layer cutRsc ["RscWLHintMenu", "PLAIN", -1, true, true];

_display = uiNamespace getVariable "RscWLHintMenu";
private _texture = _display displayCtrl 5502;
// _texture ctrlWebBrowserAction ["OpenDevConsole"];
_texture setVariable ["WL2_hintParams", _hintParams];

_texture ctrlAddEventHandler ["PageLoaded", {
    params ["_texture"];
    private _hintParams = _texture getVariable ["WL2_hintParams", []];
    if (count _hintParams < 2) exitWith {};

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
        _hintArray pushBack [_actionName, _actionKeyText];
    } forEach (_hintParams select 1);

    private _hintText = toJSON _hintArray;
    _hintText = _texture ctrlWebBrowserAction ["ToBase64", _hintText];

    private _script = format [
        "updateHint(atobr(""%1""), atobr(""%2""));",
        _hintTitle,
        _hintText
    ];
    _texture ctrlWebBrowserAction ["ExecJS", _script];
}];

if (_timeout > 0) then {
    [_timeout, _layer, _texture] spawn {
        params ["_timeout", "_layer", "_texture"];
        private _startTime = serverTime;

        waitUntil {
            serverTime - _startTime >= _timeout || isNull _texture
        };

        _layer cutText ["", "PLAIN"];
    };
};