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

private _voteSectionHeight = if (_showVote) then {
    WL_PANEL_PAD_TOP + WL_PANEL_VOTE_TITLE + (_voteSectorCount * WL_PANEL_VOTE_ROW_H) + WL_PANEL_PAD_BOTTOM
} else {
    0
};

private _totalContentHeight = _captureSectionHeight + _voteSectionHeight;
private _shouldShowPanel = _totalContentHeight > 0;

_backgroundControl ctrlSetPosition [
    WL_PANEL_X,
    0,
    WL_PANEL_W,
    _totalContentHeight
];

_backgroundControl ctrlShow _shouldShowPanel;
_backgroundControl ctrlCommit 0;

private _titleY = WL_PANEL_PAD_TOP + _captureSectionHeight;

_titleControl ctrlSetPosition [
    WL_PANEL_X,
    _titleY,
    WL_PANEL_W,
    WL_PANEL_VOTE_TITLE
];

_titleControl ctrlShow _showVote;
_titleControl ctrlCommit 0;

private _rowsY = _titleY + WL_PANEL_VOTE_TITLE;

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

    private _rowY = _rowsY + (_forEachIndex * WL_PANEL_VOTE_ROW_H);
    private _barWidth = 0;

    if (_maxVoteCount > 0) then {
        _barWidth = ((WL_PANEL_VOTE_ROW_W * (_voteCount / _maxVoteCount)) - (WL_PANEL_VOTE_BAR_GAP * 2)) max 0;
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
        WL_PANEL_VOTE_ROW_X,
        _rowY,
        WL_PANEL_VOTE_ROW_W,
        WL_PANEL_VOTE_NAME_H
    ];

    _sectorNameControl ctrlShow _showVote;
    _sectorNameControl ctrlCommit 0;

    _sectorBarControl ctrlSetBackgroundColor _color;

    _sectorBarControl ctrlSetPosition [
        WL_PANEL_VOTE_ROW_X + WL_PANEL_VOTE_BAR_GAP,
        _rowY + WL_PANEL_VOTE_BAR_OFFSET,
        _barWidth,
        WL_PANEL_VOTE_BAR_H
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