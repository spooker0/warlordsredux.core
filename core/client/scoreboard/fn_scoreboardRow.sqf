#include "includes.inc"
params ["_display", "_parent", "_position", ["_isSummary", false]];

private _width = _position # 2;
private _height = _position # 3;
private _row = _display ctrlCreate ["RscWLScoreboardGroup", -1, _parent];

_row ctrlSetPosition _position;
_row ctrlCommit 0;

private _backgroundPosition = [0, 0, _width, _height];
private _background = _display ctrlCreate ["RscText", -1, _row];

_background ctrlSetPosition _backgroundPosition;
_background ctrlSetBackgroundColor [0.25, 0.25, 0.25, 0.9];
_background ctrlCommit 0;

_row setVariable ["WL2_scoreboardBackground", _background];

private _padding = _width * 0.008;
private _innerWidth = _width - 2 * _padding;
private _columnWidths = WL_SCOREBOARD_COLUMN_WIDTHS;
private _columnX = _padding;

private _cells = [];
{
    private _columnWidth = _innerWidth * _x;
    private _isName = _forEachIndex == 1;
    private _cellClass = if (_isName) then { "RscWLScoreboardName" } else { "RscWLScoreboardCell" };
    private _namePadding = if (_isName) then { _width * 0.02 } else { 0 };
    private _cellX = _columnX + _namePadding - WL_SCOREBOARD_TEXT_MARGIN;
    private _cellWidth = _columnWidth - _namePadding + 2 * WL_SCOREBOARD_TEXT_MARGIN;
    private _cellPosition = [_cellX, 0, _cellWidth, _height];
    private _cell = _display ctrlCreate [_cellClass, -1, _row];

    _cell ctrlSetPosition _cellPosition;

    if (_isSummary) then {
        private _fontSize = WL_SCOREBOARD_TEXT_SIZE * 1.2;

        _cell ctrlSetFont "EtelkaMonospaceProBold";
        _cell ctrlSetFontHeight _fontSize;
    };

    _cell ctrlCommit 0;

    _cells pushBack _cell;
    _columnX = _columnX + _columnWidth;
} forEach _columnWidths;

_row setVariable ["WL2_scoreboardCells", _cells];

private _separatorPosition = [0, 0, _width, pixelH];
private _separator = _display ctrlCreate ["RscText", -1, _row];

_separator ctrlSetPosition _separatorPosition;
_separator ctrlSetBackgroundColor [0.4, 0.8, 1, 1];
_separator ctrlCommit 0;

_row setVariable ["WL2_scoreboardSeparator", _separator];

private _borderWidth = 2 * pixelW;
private _borderHeight = 2 * pixelH;
private _borderPositions = [
    [0, 0, _width, _borderHeight],
    [0, _height - _borderHeight, _width, _borderHeight],
    [0, 0, _borderWidth, _height],
    [_width - _borderWidth, 0, _borderWidth, _height]
];

private _borders = [];
{
    private _border = _display ctrlCreate ["RscText", -1, _row];

    _border ctrlSetPosition _x;
    _border ctrlSetBackgroundColor [1, 1, 0, 1];
    _border ctrlShow false;
    _border ctrlCommit 0;

    _borders pushBack _border;
} forEach _borderPositions;

_row setVariable ["WL2_scoreboardBorders", _borders];

_row;
