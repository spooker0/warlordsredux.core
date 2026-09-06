#include "includes.inc"
params ["_display", ["_action", "refresh"]];

if (isNull _display || !(_display getVariable ["REP_isModerator", false])) exitWith {};
if (_display getVariable ["REP_chatRefreshing", false]) exitWith {};

private _history = uiNamespace getVariable ["WL2_chatHistory", []];
private _selected = +(_display getVariable ["REP_chatSelected", []]);
private _visible = _display getVariable ["REP_chatRows", []];

private _list = _display displayCtrl REP_CHAT_IDC;
private _channelControl = _display displayCtrl REP_CHAT_CHANNEL_IDC;
private _playerControl = _display displayCtrl REP_CHAT_PLAYER_IDC;

switch (_action) do {
    case "selection": {
        _selected = _selected - _visible;
        {
            _selected pushBack parseNumber (_list lbData _x);
        } forEach lbSelection _list;
    };
    case "reset": {
        _display setVariable ["REP_chatRefreshing", true];
        _channelControl lbSetCurSel 0;
        _playerControl lbSetCurSel 0;
        _display setVariable ["REP_chatRefreshing", false];
    };
};

_selected = _selected select { _x >= 0 && _x < count _history };
_selected sort false;
_display setVariable ["REP_chatSelected", _selected];

private _channelName = {
    params ["_channel"];
    switch (_channel) do {
        case 0: { "GLOBAL" };
        case 1: { "SIDE" };
        case 2: { "COMMAND" };
        case 3: { "GROUP" };
        case 4: { "VEHICLE" };
        case 5: { "DIRECT" };
        case 6;
        case 16: { "SYSTEM" };
        default { "SQUAD" };
    };
};

_display setVariable ["REP_chatRefreshing", true];

private _channelIndex = lbCurSel _channelControl;
private _playerIndex = lbCurSel _playerControl;
private _channelFilter = _channelControl lbData _channelIndex;
private _playerFilter = _playerControl lbData _playerIndex;

if (count _history != (_display getVariable ["REP_chatHistoryCount", -1])) then {
    private _nameEntries = _history apply { [_x # 1, true] };
    private _nameMap = createHashMapFromArray _nameEntries;
    private _names = keys _nameMap;
    _names sort true;

    lbClear _playerControl;
    _playerControl lbAdd "All players";
    _playerControl lbSetData [0, ""];
    _playerControl lbSetCurSel 0;

    {
        if (_x == "") then {
            continue;
        };

        private _index = _playerControl lbAdd _x;
        _playerControl lbSetData [_index, _x];

        if (_x == _playerFilter) then {
            _playerControl lbSetCurSel _index;
        };
    } forEach _names;

    _display setVariable ["REP_chatHistoryCount", count _history];
    _playerIndex = lbCurSel _playerControl;
    _playerFilter = _playerControl lbData _playerIndex;
};

private _state = [count _history, _channelFilter, _playerFilter];
private _previousState = _display getVariable ["REP_chatState", []];
private _rebuild = _state isNotEqualTo _previousState;

if (_rebuild) then {
    private _scroll = ctrlScrollValues _list;
    if ((_previousState select [1]) isNotEqualTo [_channelFilter, _playerFilter]) then {
        _scroll = [0, 0];
    };

    lbClear _list;
    _visible = [];

    for "_index" from (count _history - 1) to 0 step -1 do {
        (_history # _index) params ["_channel", "_name", "_text", "_systemTime"];
        private _channelText = [_channel] call _channelName;

        if (_channelFilter != "" && _channelFilter != _channelText) then {
            continue;
        };
        if (_playerFilter != "" && _playerFilter != _name) then {
            continue;
        };

        private _time = [_systemTime, false] call REP_fnc_printSystemTime;
        private _line = format ["%1 [%2] %3: %4", _time, _channelText, _name, _text];
        private _row = _list lbAdd _line;
        _list lbSetData [_row, str _index];
        _list lbSetTooltip [_row, _line];
        _visible pushBack _index;
    };

    _display setVariable ["REP_chatRows", _visible];
    _display setVariable ["REP_chatState", _state];
    _list ctrlSetScrollValues _scroll;
};

private _selectionChanged = _selected isNotEqualTo (_display getVariable ["REP_chatSelection", [-1]]);
if (_rebuild || (_selectionChanged && _action != "selection")) then {
    private _selectedMap = createHashMapFromArray (_selected apply { [_x, true] });
    {
        _list lbSetSelected [_forEachIndex, _x in _selectedMap];
    } forEach _visible;
};

_display setVariable ["REP_chatRefreshing", false];
if (!_selectionChanged) exitWith {};

_display setVariable ["REP_chatSelection", +_selected];

private _preview = _selected apply {
    (_history # _x) params ["_channel", "_name", "_text", "_systemTime"];
    private _time = [_systemTime, false] call REP_fnc_printSystemTime;
    private _channelText = [_channel] call _channelName;
    format ["%1 [%2] %3: %4", _time, _channelText, _name, _text];
};
private _previewText = if (count _preview == 0) then {
    "Select messages to view and copy. Use Ctrl or Shift to select multiple messages."
} else {
    _preview joinString toString [10]
};

private _previewControl = _display displayCtrl REP_CHAT_PREVIEW_IDC;
if (ctrlText _previewControl != _previewText) then {
    _previewControl ctrlSetText _previewText;
};

private _copyLines = _selected apply {
    private _message = _history # _x;
    private _name = _message # 1;
    private _text = _message # 2;

    if (_name == "") then {
        _text
    } else {
        format ["%1: %2", _name, _text]
    };
};
private _copyText = _copyLines joinString toString [10];
private _copyLabel = format ["COPY CHAT (%1)", count _selected];

private _onCopy = {
    params ["_control", "_text", "_copied"];
    private _display = ctrlParent _control;
    private _selected = _display getVariable ["REP_chatSelected", []];
    _display setVariable ["REP_chatSelected", _selected - _copied];
    [_display] call REP_fnc_chat;
};

private _copyControl = _display displayCtrl REP_COPY_CHAT_IDC;
[_copyControl, _copyText, _copyLabel, _onCopy, +_selected] call REP_fnc_setCopyButton;
