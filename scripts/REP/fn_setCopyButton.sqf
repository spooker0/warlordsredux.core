#include "includes.inc"
params ["_control", "_text", ["_label", localize "STR_WL_copy"], ["_onCopy", {}], ["_data", []]];
disableSerialization;

if (isNull _control) exitWith {};

private _copyStrings = [
    localize "STR_WL_copied",
    localize "STR_WL_copyTooltip",
    localize "STR_WL_copySuccess",
    localize "STR_WL_copyFailed"
];

private _previousState = _control getVariable ["REP_copyState", ["", "", {}, []]];
private _previousStrings = _control getVariable ["REP_copyStrings", []];
private _changed = (
    _text != _previousState # 0 ||
    _label != _previousState # 1 ||
    _data isNotEqualTo (_previousState # 3) ||
    _copyStrings isNotEqualTo _previousStrings
);

private _revision = _control getVariable ["REP_copyRevision", 0];
if (_changed) then {
    _revision = _revision + 1;
    _control setVariable ["REP_copyRevision", _revision];
};

_control setVariable ["REP_copyState", [_text, _label, _onCopy, +_data]];
_control setVariable ["REP_copyStrings", _copyStrings];

if !(_control getVariable ["REP_copyInitialized", false]) then {
    _control setVariable ["REP_copyInitialized", true];

    _control ctrlAddEventHandler ["PageLoaded", {
        params ["_control"];
        _control setVariable ["REP_copyReady", true];
        _control setVariable ["REP_copySentRevision", -1];

        private _state = _control getVariable ["REP_copyState", ["", "", {}, []]];
        _state params ["_text", "_label", "_onCopy", "_data"];
        [_control, _text, _label, _onCopy, _data] call REP_fnc_setCopyButton;
    }];

    _control ctrlAddEventHandler ["JSDialog", {
        params ["_control", "_isConfirmDialog", "_message"];
        private _response = fromJSON _message;
        if !(_response isEqualType [] && { count _response == 2 }) exitWith { true };

        _response params ["_action", "_revision"];
        private _currentRevision = _control getVariable ["REP_copyRevision", -1];
        if (_revision != _currentRevision) exitWith { true };

        private _copyStrings = _control getVariable ["REP_copyStrings", ["", "", "", ""]];
        if (_action == "failed") exitWith {
            private _failureText = _copyStrings # 3;
            systemChat _failureText;
            true;
        };

        if (_action != "copied") exitWith { true };
        private _completedRevision = _control getVariable ["REP_copyCompletedRevision", -1];
        if (_revision == _completedRevision) exitWith { true };

        private _state = _control getVariable ["REP_copyState", ["", "", {}, []]];
        _state params ["_text", "_label", "_onCopy", "_data"];
        if (_text == "") exitWith { true };

        _control setVariable ["REP_copyCompletedRevision", _revision];
        private _successText = _copyStrings # 2;
        systemChat _successText;
        [_control, _text, _data] call _onCopy;
        true;
    }];

    _control ctrlWebBrowserAction ["LoadFile", "src\ui\gen\copy.html"];
};

if !(_control getVariable ["REP_copyReady", false]) exitWith {};
private _sentRevision = _control getVariable ["REP_copySentRevision", -1];
if (_revision == _sentRevision) exitWith {};

private _payload = toJSON [_text, _label, _revision, _copyStrings];
_payload = _control ctrlWebBrowserAction ["ToBase64", _payload];

private _script = format ["setCopyButton(""%1"");", _payload];
_control ctrlWebBrowserAction ["ExecJS", _script];
_control setVariable ["REP_copySentRevision", _revision];
