#include "includes.inc"
params ["_display"];
if (isNull _display) exitWith {};

private _content = _display displayCtrl WL_SCOREBOARD_CONTENT_ID;
private _rows = _display getVariable ["WL2_scoreboardRows", [[], []]];
private _summaries = _display getVariable ["WL2_scoreboardSummaries", []];

private _scoreboardData = missionNamespace getVariable ["WL2_scoreboardResults", []];
private _playerUid = getPlayerUID player;

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
    params ["_cell", "_text", "_suffix"];

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

    while { _minLength <= _maxLength } do {
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

    private _cells = _row getVariable ["WL2_scoreboardCells", []];

    {
        private _cell = _cells # _forEachIndex;
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
            private _nameCell = _cells # 1;

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
