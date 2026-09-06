#include "includes.inc"
params ["_display"];
if (isNull _display) exitWith {};

private _moderate = _display getVariable ["REP_isModerator", false];
private _searchControl = _display displayCtrl REP_SEARCH_IDC;
private _search = toLower ctrlText _searchControl;
private _aliases = missionProfileNamespace getVariable ["WL2_playerAliases", createHashMap];
private _allPlayers = call BIS_fnc_listPlayers;
_allPlayers = [_allPlayers, [], { toLower ([_x] call BIS_fnc_getName) }, "ASCEND"] call BIS_fnc_sortBy;

private _rows = [];
{
    private _uid = getPlayerUID _x;
    if (_uid == "") then {
        continue;
    };

    private _name = [_x] call BIS_fnc_getName;
    private _names = [];
    private _reportCount = 0;
    private _searchParts = [_name];

    if (_moderate) then {
        private _knownNames = _aliases getOrDefault [_uid, []];
        private _reports = _x getVariable ["WL2_playerReports", createHashMap];
        _names = _knownNames select { _x != "" && _x != _name };
        _reportCount = count _reports;
        _searchParts append [_names joinString " ", _uid];
    };

    private _searchText = toLower (_searchParts joinString " ");
    if (_search != "" && _searchText find _search == -1) then {
        continue;
    };

    _rows pushBack [_uid, _name, _names, _reportCount];
} forEach _allPlayers;

private _playersGroup = _display displayCtrl REP_PLAYERS_IDC;
private _selectedUid = _display getVariable ["REP_selectedUid", ""];
private _previousRows = _display getVariable ["REP_playerRows", []];

if (_rows isNotEqualTo _previousRows) then {
    private _scroll = ctrlScrollValues _playersGroup;
    private _oldControls = _display getVariable ["REP_playerControls", []];
    {
        ctrlDelete _x;
    } forEach _oldControls;

    private _controls = [];
    private _buttons = [];
    private _groupPosition = ctrlPosition _playersGroup;
    private _width = (_groupPosition # 2) - safeZoneW * 0.014;
    private _currentY = 0;

    {
        _x params ["_uid", "_name", "_names", "_reportCount"];

        private _nameCharacters = toArray _name;
        private _escapedCharacters = _nameCharacters apply {
            switch (_x) do {
                case 38: { "&amp;" };
                case 60: { "&lt;" };
                case 62: { "&gt;" };
                default { toString [_x] };
            };
        };
        private _escapedName = _escapedCharacters joinString "";
        private _buttonText = format ["<t align='left' color='#ffffff'>%1</t>", _escapedName];
        private _buttonTooltip = _name;

        if (_moderate) then {
            _buttonText = _buttonText + format ["<t align='right' color='#ff5555'>%1</t>", _reportCount];
            _buttonTooltip = format ["%1 | %2 | %3 reports", _name, _uid, _reportCount];
        };

        private _button = _display ctrlCreate ["REP_PlayerButton", -1, _playersGroup];

        _button ctrlSetPosition [REP_LAYOUT_PLAYER_PADDING, _currentY, _width, REP_LAYOUT_PLAYER_H];
        _button ctrlSetStructuredText parseText _buttonText;
        _button ctrlSetTooltip _buttonTooltip;

        _button setVariable ["REP_playerUid", _uid];
        _button setVariable ["REP_playerName", _escapedName];
        _button setVariable ["REP_reportCount", _reportCount];

        _button ctrlAddEventHandler ["ButtonClick", {
            params ["_button"];
            private _display = ctrlParent _button;
            private _uid = _button getVariable ["REP_playerUid", ""];
            [_display, _uid] call REP_fnc_selectPlayer;
        }];
        _button ctrlCommit 0;

        _controls pushBack _button;
        _buttons pushBack [_button, _uid];
        _currentY = _currentY + REP_LAYOUT_PLAYER_H;

        if (count _names > 0) then {
            private _aliasesControl = _display ctrlCreate ["REP_AliasText", -1, _playersGroup];
            private _aliasesX = REP_LAYOUT_PLAYER_PADDING + safeZoneW * 0.008;
            private _aliasesWidth = _width - safeZoneW * 0.008;
            private _aliasesText = _names joinString ", ";

            _currentY = _currentY + REP_LAYOUT_ALIAS_GAP;
            _aliasesControl ctrlSetPosition [_aliasesX, _currentY, _aliasesWidth, REP_LAYOUT_PLAYER_H];
            _aliasesControl ctrlSetText _aliasesText;
            _aliasesControl ctrlEnable false;
            _aliasesControl ctrlCommit 0;

            private _aliasesHeight = ctrlTextHeight _aliasesControl;
            _aliasesControl ctrlSetPosition [_aliasesX, _currentY, _aliasesWidth, _aliasesHeight];
            _aliasesControl ctrlCommit 0;

            _controls pushBack _aliasesControl;
            _currentY = _currentY + _aliasesHeight;
        };
        _currentY = _currentY + REP_LAYOUT_PLAYER_GAP;
    } forEach _rows;

    _display setVariable ["REP_playerControls", _controls];
    _display setVariable ["REP_playerButtons", _buttons];
    _display setVariable ["REP_playerRows", _rows];
    _playersGroup ctrlSetScrollValues _scroll;
};

private _selectedIndex = _rows findIf { _x # 0 == _selectedUid };
if (_selectedIndex == -1) then {
    _selectedUid = "";
};
[_display, _selectedUid] call REP_fnc_selectPlayer;

if (!_moderate) exitWith {};

private _timeouts = _display displayCtrl REP_TIMEOUTS_IDC;
private _timeoutIndex = lbCurSel _timeouts;
private _timeoutUid = _timeouts lbData _timeoutIndex;
private _punishments = missionNamespace getVariable ["WL2_punishmentMap", createHashMap];

lbClear _timeouts;
{
    _y params ["_endTime", "_reason"];
    if (_endTime <= serverTime) then {
        continue;
    };

    private _uid = _x;
    private _playerIndex = _allPlayers findIf { getPlayerUID _x == _uid };
    private _name = if (_playerIndex >= 0) then {
        [_allPlayers # _playerIndex] call BIS_fnc_getName
    } else {
        _uid
    };

    private _remaining = ceil (_endTime - serverTime);
    private _timeoutText = format ["%1s", _remaining];
    private _timeoutTooltip = format ["%1: %2", _uid, _reason];
    private _index = _timeouts lbAdd _name;

    _timeouts lbSetData [_index, _uid];
    _timeouts lbSetTextRight [_index, _timeoutText];
    _timeouts lbSetTooltip [_index, _timeoutTooltip];
    if (_uid == _timeoutUid) then {
        _timeouts lbSetCurSel _index;
    };
} forEach _punishments;

private _clearTimeoutButton = _display displayCtrl REP_CLEAR_TIMEOUT_IDC;
private _hasTimeout = lbCurSel _timeouts >= 0;
_clearTimeoutButton ctrlEnable _hasTimeout;

private _receipts = missionProfileNamespace getVariable ["WL2_infoDisplay", ""];
private _receiptLines = _receipts splitString toString [10];
private _receiptCount = { _x select [0, 6] == "[NAME]" } count _receiptLines;
private _receiptLabel = format ["Copy receipts (%1)", _receiptCount];
private _receiptsButton = _display displayCtrl REP_RECEIPTS_IDC;

[_receiptsButton, _receipts, _receiptLabel, {
    params ["_control", "_capturedText", "_data"];
    private _receipts = missionProfileNamespace getVariable ["WL2_infoDisplay", ""];
    private _capturedLength = count _capturedText;
    private _receiptPrefix = _receipts select [0, _capturedLength];

    if (_receiptPrefix == _capturedText) then {
        private _remainingReceipts = _receipts select [_capturedLength];
        missionProfileNamespace setVariable ["WL2_infoDisplay", _remainingReceipts];
    };

    private _display = ctrlParent _control;
    [_display] call REP_fnc_refresh;
}] call REP_fnc_setCopyButton;

[_display] call REP_fnc_chat;
