#include "includes.inc"
params ["_display", "_voteSectors", "_captureSectionHeight", "_showVote"];

private _backgroundControl = _display displayCtrl 4000;
private _titleControl = _display displayCtrl 4002;
private _sectorRowControls = _display getVariable ["WL2_sectorRowControls", []];

private _voteSectorCount = count _voteSectors;

private _maxVoteCount = if (_voteSectorCount > 0) then {
    selectMax (_voteSectors apply { _x # 1 })
} else {
    0
};

private _panelWidth = 0.3;
private _panelX = safeZoneX + safeZoneW - _panelWidth - 0.02;
private _panelY = 0;

private _paddingX = 0.005;
private _paddingTop = 0.02;
private _paddingBottom = 0.01;

private _titleHeight = 0.075;
private _titleRowsGap = 0.0;

private _nameHeight = 0.022;
private _barHeight = 0.004;
private _barOffsetY = 0.026;
private _rowHeight = _nameHeight + _barHeight + 0.02;
private _barGapX = 0.01;

private _voteSectionHeight = if (_showVote) then {
    _paddingTop + _titleHeight + _titleRowsGap + (_voteSectorCount * _rowHeight) + _paddingBottom
} else {
    0
};

private _totalContentHeight = _captureSectionHeight + _voteSectionHeight;
private _shouldShowPanel = _totalContentHeight > 0;

_backgroundControl ctrlSetPosition [
    _panelX,
    _panelY,
    _panelWidth,
    _totalContentHeight
];

_backgroundControl ctrlShow _shouldShowPanel;
_backgroundControl ctrlCommit 0;

private _titleY = _panelY + _paddingTop + _captureSectionHeight;

_titleControl ctrlSetPosition [
    _panelX,
    _titleY,
    _panelWidth,
    _titleHeight
];

_titleControl ctrlShow _showVote;
_titleControl ctrlCommit 0;

private _rowsX = _panelX + _paddingX;
private _rowsY = _titleY + _titleHeight + _titleRowsGap;
private _rowsWidth = _panelWidth - (_paddingX * 2);

{
    _x params ["_sectorName", "_voteCount", "_color"];

    private _sectorRowControlPair = if (_forEachIndex < count _sectorRowControls) then {
        _sectorRowControls # _forEachIndex
    } else {
        private _sectorNameControl = _display ctrlCreate ["RscWLSectorDisplay_SectorName", -1];
        private _sectorBarControl = _display ctrlCreate ["RscWLSectorDisplay_SectorBar", -1];

        _sectorRowControls pushBack [_sectorNameControl, _sectorBarControl];
        [_sectorNameControl, _sectorBarControl]
    };

    _sectorRowControlPair params ["_sectorNameControl", "_sectorBarControl"];

    private _rowY = _rowsY + (_forEachIndex * _rowHeight);
    private _barWidth = 0;

    if (_maxVoteCount > 0) then {
        _barWidth = ((_rowsWidth * (_voteCount / _maxVoteCount)) - (_barGapX * 2)) max 0;
    };

    private _voteCountDisplay = switch (true) do {
        case (_voteCount >= 1000000): {
            format ["%1M", (_voteCount / 1000000) toFixed 1]
        };
        case (_voteCount >= 1000): {
            format ["%1K", (_voteCount / 1000) toFixed 1]
        };
        default {
            str _voteCount
        };
    };

    _sectorNameControl ctrlSetStructuredText parseText format [
        "<t>%1</t><t align='right'>%2</t>",
        toUpper _sectorName,
        _voteCountDisplay
    ];

    _sectorNameControl ctrlSetPosition [
        _rowsX,
        _rowY,
        _rowsWidth,
        _nameHeight
    ];

    _sectorNameControl ctrlShow _showVote;
    _sectorNameControl ctrlCommit 0;

    _sectorBarControl ctrlSetBackgroundColor _color;

    _sectorBarControl ctrlSetPosition [
        _rowsX + _barGapX,
        _rowY + _barOffsetY,
        _barWidth,
        _barHeight
    ];

    _sectorBarControl ctrlShow _showVote;
    _sectorBarControl ctrlCommit 0;
} forEach _voteSectors;

{
    _x params ["_sectorNameControl", "_sectorBarControl"];

    private _shouldShow = _showVote && { _forEachIndex < _voteSectorCount };

    _sectorNameControl ctrlShow _shouldShow;
    _sectorBarControl ctrlShow _shouldShow;
} forEach _sectorRowControls;

_display setVariable ["WL2_sectorRowControls", _sectorRowControls];