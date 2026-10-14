#include "includes.inc"
params ["_display", ["_device", ""], ["_key", -1], ["_down", false], ["_modifiers", []]];
private _closed = _display getVariable ["TUT_closed", true];
if (isNull _display || _closed) exitWith {};

private _holdToSkip = _display getVariable ["TUT_holdToSkip", false];
if (!_holdToSkip) exitWith {
    if (_device == "KEYBOARD" && _key == 1 && _down) then {
        _display closeDisplay 2;
    };
};

private _pressed = _display getVariable ["TUT_skipKeys", []];
private _mods = _display getVariable ["TUT_skipModifiers", [false, false, false]];
if (!isGameFocused) then {
    _pressed = [];
    _mods = [false, false, false];
} else {
    if (_key >= 0) then {
        private _token = format ["%1:%2", _device, _key];
        if (_down) then {
            _pressed pushBackUnique _token;
        } else {
            _pressed = _pressed - [_token];
        };
        if (count _modifiers == 3) then {
            _mods = +_modifiers;
        };
        if (_device == "KEYBOARD" && !_down) then {
            // KeyUp flags can still include the modifier that is being released.
            if (_key in [42, 54]) then {
                _mods set [0, false];
            };
            if (_key in [29, 157]) then {
                _mods set [1, false];
            };
            if (_key in [56, 184]) then {
                _mods set [2, false];
            };
        };
    };
};
_display setVariable ["TUT_skipKeys", _pressed];
_display setVariable ["TUT_skipModifiers", _mods];

private _isPressed = {
    params ["_input", ["_allowModifier", false]];
    _input params ["_code", "_type"];
    if (_type == "MOUSE_BUTTON") then {
        _code = _code % 128;
    };
    if ((format ["%1:%2", _type, _code]) in _pressed) exitWith { true };
    if (_type != "KEYBOARD" || !_allowModifier) exitWith { false };
    // Also recognize a modifier already held when the cinematic opened.
    private _group = switch (_code) do {
        case 42;
        case 54: { 0 };
        case 29;
        case 157: { 1 };
        case 56;
        case 184: { 2 };
        default { -1 };
    };
    if (_group < 0) exitWith { false };
    private _keys = [[42, 54], [29, 157], [56, 184]] # _group;
    (_mods # _group) && { (_keys findIf { (format ["KEYBOARD:%1", _x]) in _pressed }) == -1 }
};
private _bindings = _display getVariable ["TUT_skipBindings", []];
private _holding = isGameFocused && {
    (_bindings findIf {
        _x params ["_main", "_combo"];
        ([_main] call _isPressed) && { count _combo == 0 || { [_combo, true] call _isPressed } }
    }) != -1
};
private _started = _display getVariable ["TUT_skipStart", -1];
if (!_holding) then {
    _started = -1;
} else {
    if (_started < 0) then {
        _started = diag_tickTime;
    };
};
_display setVariable ["TUT_skipStart", _started];
private _progress = if (_started < 0) then { 0 } else { ((diag_tickTime - _started) / 1.5) min 1 };
(_display displayCtrl TUT_SKIP_FILL_IDC) progressSetPosition _progress;
if (_progress >= 1) then {
    _display closeDisplay 2;
};
