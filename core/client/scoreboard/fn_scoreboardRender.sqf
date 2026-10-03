#include "includes.inc"
params ["_display"];
if (isNull _display) exitWith {};

private _content = _display displayCtrl WL_SCOREBOARD_CONTENT_ID;
if (isNull _content) exitWith {};

disableSerialization;

private _rows = _display getVariable ["WL2_scoreboardRows", [[], []]];
private _summaries = _display getVariable ["WL2_scoreboardSummaries", []];

private _scoreboardData = missionNamespace getVariable ["WL2_scoreboardResults", []];
private _playerUid = getPlayerUID player;
private _connectedUids = createHashMap;
{
    private _uid = getPlayerUID _x;
    if (_uid != "") then {
        _connectedUids set [_uid, true];
    };
} forEach allPlayers;

private _sideNames = ["BLUFOR", "OPFOR"];
private _sideColors = [[0.4, 0.8, 1, 1], [1, 0.5, 0.5, 1]];
private _teamPlayers = [[], []];
private _teamRatings = [0, 0];
private _teamCounts = [0, 0];
private _statKeys = [
    "kills",
    "staticKills",
    "lightKills",
    "heavyKills",
    "heloKills",
    "planeKills",
    "deaths",
    "points"
];

#if WL_SCOREBOARD_TEST
// Cache mock data on this display without changing the server's results.
private _mockData = _display getVariable ["WL2_scoreboardMockData", []];
if (_mockData isEqualTo []) then {
    private _mockResults = [];
    private _mockConnected = createHashMap;
    private _localSide = [west, east] find (side group player);
    {
        private _sideIndex = _forEachIndex;
        private _sideName = _x;
        for "_i" from 1 to 40 do {
            private _uid = format ["scoreboard_test_%1_%2", _sideIndex, _i];
            private _name = format ["Test Player %1", _i];
            if (_i % 5 == 0) then {
                _name = format ["Test Player %1 With A Very Long Name For Truncation", _i];
            };
            if (_i == 1 && { _sideIndex == _localSide } && { _playerUid != "" }) then {
                _uid = _playerUid;
                _name = name player;
            };
            if (_i % 3 != 0) then {
                _mockConnected set [_uid, true];
            };
            private _entry = createHashMapFromArray [
                ["uid", _uid], ["name", _name], ["side", _sideName],
                ["rating", 1000 + _i * 25]
            ];
            {
                _entry set [_x, (41 - _i) * (_forEachIndex + 1)];
            } forEach _statKeys;
            _entry set ["points", if (_i == 1) then { 1250000 } else { (41 - _i) * 1250 }];
            _mockResults pushBack _entry;
        };
    } forEach _sideNames;
    _mockData = [_mockResults, _mockConnected];
    _display setVariable ["WL2_scoreboardMockData", _mockData];
};
_scoreboardData = _mockData # 0;
_connectedUids = _mockData # 1;
#endif

private _formatScore = {
    params ["_value"];
    if (_value < 1000) exitWith { str _value };

    if (_value < 1000000) exitWith {
        private _thousands = _value / 1000;
        private _scoreText = _thousands toFixed 1;

        _scoreText + "K"
    };

    private _millions = _value / 1000000;
    private _scoreText = _millions toFixed 1;

    _scoreText + "M"
};

private _setCellText = {
    params [["_cell", controlNull, [controlNull]], "_text", "_suffix"];
    if (isNull _cell) exitWith {};

    private _fullText = _text + _suffix;
    private _previousText = _cell getVariable ["WL2_scoreboardText", ""];
    if (_previousText == _fullText) exitWith {};

    _cell setVariable ["WL2_scoreboardText", _fullText];

    _cell ctrlSetText _fullText;
    if (_suffix == "") exitWith {};

    private _cellPosition = ctrlPosition _cell;
    private _availableWidth = (_cellPosition # 2) - 2 * pixelW;
    private _textWidth = ctrlTextWidth _cell;

    if (_textWidth <= _availableWidth) exitWith {};

    private _minLength = 0;
    private _maxLength = count _text - 1;
    private _fittedText = _suffix;

    // The scoreboard can close while this scheduled render is suspended.
    while { !isNull _cell && { _minLength <= _maxLength } } do {
        private _length = floor ((_minLength + _maxLength) / 2);
        private _shortenedName = _text select [0, _length];
        private _candidate = _shortenedName + "…" + _suffix;

        _cell ctrlSetText _candidate;

        _textWidth = ctrlTextWidth _cell;
        if (_textWidth <= _availableWidth) then {
            _fittedText = _candidate;
            _minLength = _length + 1;
        } else {
            _maxLength = _length - 1;
        };
    };

    _cell ctrlSetText _fittedText;
};

private _updateRow = {
    params ["_row", "_values", "_ratingSuffix"];
    if (isNull _row) exitWith {};

    private _cells = _row getVariable ["WL2_scoreboardCells", []];

    {
        private _cell = _cells param [_forEachIndex, controlNull];
        private _suffix = if (_forEachIndex == 1) then { _ratingSuffix } else { "" };

        [_cell, _x, _suffix] call _setCellText;
    } forEach _values;
};

{
    private _sideName = _x getOrDefault ["side", ""];
    private _sideIndex = _sideNames find _sideName;

    if (_sideIndex == -1) then {
        continue;
    };

    private _players = _teamPlayers # _sideIndex;

    _players pushBack _x;
} forEach _scoreboardData;

{
    private _side = side group _x;
    private _sideIndex = [west, east] find _side;

    if (_sideIndex == -1) then {
        continue;
    };

    private _rating = _x getVariable ["WL2_playerRating", WL_RATING_STARTER];
    private _totalRating = _teamRatings # _sideIndex;
    private _playerCount = _teamCounts # _sideIndex;

    _teamRatings set [_sideIndex, _totalRating + _rating];
    _teamCounts set [_sideIndex, _playerCount + 1];
} forEach allPlayers;

#if WL_SCOREBOARD_TEST
_teamRatings = [0, 0];
_teamCounts = [0, 0];
{
    private _sideIndex = _forEachIndex;
    {
        if ((_x getOrDefault ["uid", ""]) in _connectedUids) then {
            _teamRatings set [_sideIndex, (_teamRatings # _sideIndex) + (_x get "rating")];
            _teamCounts set [_sideIndex, (_teamCounts # _sideIndex) + 1];
        };
    } forEach _x;
} forEach _teamPlayers;
#endif

{
    private _sideIndex = _forEachIndex;
    private _players = _x;
    private _teamRows = _rows # _sideIndex;
    private _teamColor = _sideColors # _sideIndex;
    private _teamTotals = [0, 0, 0, 0, 0, 0, 0, 0];
    private _rowX = _sideIndex * (WL_SCOREBOARD_PANEL_W + WL_SCOREBOARD_GAP);
    private _playerCount = count _players;

    while { count _teamRows > _playerCount } do {
        private _lastRowIndex = count _teamRows - 1;
        private _staleRow = _teamRows deleteAt _lastRowIndex;

        ctrlDelete _staleRow;
    };

    {
        if (isNull _display) exitWith {};

        private _entry = _x;
        private _rowIndex = _forEachIndex;

        if (_rowIndex >= count _teamRows) then {
            private _rowY = _rowIndex * WL_SCOREBOARD_ROW_H;
            private _rowPosition = [_rowX, _rowY, WL_SCOREBOARD_PANEL_W, WL_SCOREBOARD_ROW_H];
            private _row = [_display, _content, _rowPosition] call WL2_fnc_scoreboardRow;

            private _rowAlpha = if (_rowIndex % 2 == 0) then { 0.9 } else { 0.95 };
            private _rowColor = [0.25, 0.25, 0.25, _rowAlpha];

            private _background = _row getVariable ["WL2_scoreboardBackground", controlNull];
            private _cells = _row getVariable ["WL2_scoreboardCells", []];
            private _nameCell = _cells param [1, controlNull];

            _background ctrlSetBackgroundColor _rowColor;
            _nameCell ctrlSetTextColor _teamColor;

            _teamRows pushBack _row;
        };

        private _row = _teamRows # _rowIndex;
        private _stats = [];

        {
            private _value = _entry getOrDefault [_x, 0];

            if !(_value isEqualType 0) then {
                _value = 0;
            };

            private _total = _teamTotals # _forEachIndex;

            _teamTotals set [_forEachIndex, _total + _value];
            _stats pushBack _value;
        } forEach _statKeys;

        private _name = _entry getOrDefault ["name", ""];
        private _rating = _entry getOrDefault ["rating", WL_RATING_STARTER];
        private _ratingSuffix = format [" (%1)", _rating];

        private _rank = _rowIndex + 1;
        private _rankText = [_rank] call _formatScore;
        private _values = [_rankText, _name];
        private _formattedStats = _stats apply { [_x] call _formatScore };

        _values append _formattedStats;

        [_row, _values, _ratingSuffix] call _updateRow;

        private _entryUid = _entry getOrDefault ["uid", ""];
        private _isDisconnected = _entryUid != "" && { !(_entryUid in _connectedUids) };
        private _strike = _row getVariable ["WL2_scoreboardStrike", controlNull];

        if (_isDisconnected) then {
            private _cells = _row getVariable ["WL2_scoreboardCells", []];
            private _nameCell = _cells # 1;
            private _namePosition = ctrlPosition _nameCell;
            private _strikeWidth = (ctrlTextWidth _nameCell - 2 * WL_SCOREBOARD_TEXT_MARGIN) max 0;
            private _availableWidth = ((_namePosition # 2) - 2 * WL_SCOREBOARD_TEXT_MARGIN) max 0;

            _strike ctrlSetPosition [
                (_namePosition # 0) + WL_SCOREBOARD_TEXT_MARGIN,
                (_namePosition # 1) + ((_namePosition # 3) - pixelH) / 2,
                _strikeWidth min _availableWidth,
                pixelH
            ];
            _strike ctrlSetBackgroundColor [1, 1, 1, 1];
            _strike ctrlCommit 0;
        };

        // Rows are reused when rankings change; always refresh their connection state.
        _strike ctrlShow _isDisconnected;

        private _isPlayer = _playerUid != "" && { _entryUid == _playerUid };
        private _wasPlayer = _row getVariable ["WL2_scoreboardPlayer", false];

        if (_isPlayer != _wasPlayer) then {
            private _borders = _row getVariable ["WL2_scoreboardBorders", []];

            {
                _x ctrlShow _isPlayer;
            } forEach _borders;

            _row setVariable ["WL2_scoreboardPlayer", _isPlayer];
        };
    } forEach _players;

    if (isNull _display) exitWith {};

    private _totalRating = _teamRatings # _sideIndex;
    private _connectedPlayers = _teamCounts # _sideIndex;
    private _averageRating = if (_connectedPlayers > 0) then {
        _totalRating / _connectedPlayers
    } else {
        WL_RATING_STARTER
    };

    private _sideName = _sideNames # _sideIndex;
    private _ratingSuffix = format [" (%1)", _averageRating];
    private _summaryValues = ["", _sideName];
    private _formattedTotals = _teamTotals apply { [_x] call _formatScore };

    _summaryValues append _formattedTotals;

    private _summary = _summaries # _sideIndex;

    [_summary, _summaryValues, _ratingSuffix] call _updateRow;
} forEach _teamPlayers;

if (isNull _display) exitWith {};

_display setVariable ["WL2_scoreboardRows", _rows];

private _bluforCount = count (_teamPlayers # 0);
private _opforCount = count (_teamPlayers # 1);
private _rowCount = _bluforCount max _opforCount;
private _contentHeight = (_rowCount * WL_SCOREBOARD_ROW_H) max WL_SCOREBOARD_BODY_H;
private _contentPosition = ctrlPosition _content;

if ((_contentPosition # 3) != _contentHeight) then {
    _content ctrlSetPositionH _contentHeight;
    _content ctrlCommit 0;
};

private _maxScroll = (_contentHeight - WL_SCOREBOARD_BODY_H) max 0;

_display setVariable ["WL2_scoreboardMaxScroll", _maxScroll];

[0] call WL2_fnc_scoreboardScroll;
