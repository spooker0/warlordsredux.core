#include "includes.inc"
params ["_display", "_sectorCaptureList", "_showVote"];

private _backgroundControl = _display displayCtrl 4000;
private _captureTitleControl = _display displayCtrl 4001;
private _captureRowControls = _display getVariable ["WL2_captureRowControls", []];

private _captureRowControlsVersion = _display getVariable ["WL2_captureRowControlsVersion", 0];

if (_captureRowControlsVersion != 2) then {
    {
        {
            ctrlDelete _x;
        } forEach _x;
    } forEach _captureRowControls;

    _captureRowControls = [];
    _display setVariable ["WL2_captureRowControls", _captureRowControls];
    _display setVariable ["WL2_captureRowControlsVersion", 2];
};

private _captureSectorCount = count _sectorCaptureList;

private _panelX = safeZoneX + safeZoneW - 0.42;
private _panelY = 0;
private _panelWidth = 0.4;

private _paddingX = 0.02;
private _paddingTop = 0.03;

private _titleHeight = 0.055;

private _rowHeight = 0.086;
private _nameHeight = 0.024;
private _barHeight = 0.03;
private _barOffsetY = 0.032;
private _captureVoteGap = 0.05;

private _barGapX = 0.01;

private _rowsX = _panelX + _paddingX;
private _rowsY = _panelY + _paddingTop + _titleHeight;
private _rowsWidth = _panelWidth - (_paddingX * 2);

private _barX = _rowsX + _barGapX;
private _barWidth = _rowsWidth - (_barGapX * 2);

private _percentWidth = 0.1;
private _directionWidth = 0.1;
private _directionMargin = 0.006;

private _percentX = _barX + ((_barWidth - _percentWidth) / 2);
private _directionLeftX = _percentX - _directionMargin - _directionWidth;
private _directionRightX = _percentX + _percentWidth + _directionMargin;

private _shouldShowCapture = _captureSectorCount > 0;

if (!isNull _captureTitleControl) then {
    _captureTitleControl ctrlSetStructuredText parseText "<t align='center'>CAPTURE PROGRESS</t>";
    _captureTitleControl ctrlSetPosition [
        _panelX,
        _panelY + _paddingTop,
        _panelWidth,
        _titleHeight
    ];
    _captureTitleControl ctrlShow _shouldShowCapture;
    _captureTitleControl ctrlCommit 0;
};

private _sideColor = {
    params ["_side"];

    switch (_side) do {
        case west: { [0, 0.3, 0.6, 1] };
        case east: { [0.5, 0, 0, 1] };
        case independent: { [0, 0.5, 0, 1] };
        default { [0.7, 0.6, 0, 1] };
    };
};

private _formatCap = {
    params ["_value"];

    if (_value isEqualType 0) then {
        if (_value == round _value) then {
            str round _value
        } else {
            _value toFixed 1
        }
    } else {
        str _value
    }
};

{
    _x params [
        "_sectorName",
        "_capturingTeamCap",
        "_defendingTeamCap",
        "_captureProgressPercent",
        "_captureProgressDisplay",
        "_captureProgressDirection",
        "_captureProgressDirectionSide",
        "_capturingTeam",
        "_defendingTeam"
    ];

    private _captureRowControlSet = if (_forEachIndex < count _captureRowControls) then {
        _captureRowControls # _forEachIndex
    } else {
        private _capTextControl = _display ctrlCreate ["RscWLSectorDisplay_SectorName", -1];
        private _sectorNameControl = _display ctrlCreate ["RscWLSectorDisplay_SectorName", -1];

        private _defenderBarControl = _display ctrlCreate ["RscWLSectorDisplay_SectorBar", -1];
        private _attackerBarControl = _display ctrlCreate ["RscWLSectorDisplay_SectorBar", -1];

        private _progressPercentControl = _display ctrlCreate ["RscWLSectorDisplay_SectorName", -1];
        private _progressDirectionControl = _display ctrlCreate ["RscWLSectorDisplay_SectorName", -1];

        _captureRowControls pushBack [
            _capTextControl,
            _sectorNameControl,
            _defenderBarControl,
            _attackerBarControl,
            _progressPercentControl,
            _progressDirectionControl
        ];

        [
            _capTextControl,
            _sectorNameControl,
            _defenderBarControl,
            _attackerBarControl,
            _progressPercentControl,
            _progressDirectionControl
        ]
    };

    _captureRowControlSet params [
        "_capTextControl",
        "_sectorNameControl",
        "_defenderBarControl",
        "_attackerBarControl",
        "_progressPercentControl",
        "_progressDirectionControl"
    ];

    private _rowY = _rowsY + (_forEachIndex * _rowHeight);

    private _attackerColor = [_capturingTeam] call _sideColor;
    private _defenderColor = [_defendingTeam] call _sideColor;

    private _progress = ((_captureProgressPercent / 100) max 0) min 1;
    private _attackerBarWidth = _barWidth * _progress;

    private _attackerCapDisplay = [_capturingTeamCap] call _formatCap;
    private _defenderCapDisplay = [_defendingTeamCap] call _formatCap;

    _capTextControl ctrlSetStructuredText parseText format [
        "<t align='left'>%1</t><t align='right'>%2</t>",
        _attackerCapDisplay,
        _defenderCapDisplay
    ];

    _capTextControl ctrlSetPosition [
        _rowsX,
        _rowY,
        _rowsWidth,
        _nameHeight
    ];

    _capTextControl ctrlShow true;
    _capTextControl ctrlCommit 0;

    _sectorNameControl ctrlSetStructuredText parseText format [
        "<t align='center'>%1</t>",
        toUpper _sectorName
    ];

    _sectorNameControl ctrlSetPosition [
        _rowsX,
        _rowY,
        _rowsWidth,
        _nameHeight
    ];

    _sectorNameControl ctrlShow true;
    _sectorNameControl ctrlCommit 0;

    _defenderBarControl ctrlSetBackgroundColor _defenderColor;
    _defenderBarControl ctrlSetPosition [
        _barX,
        _rowY + _barOffsetY,
        _barWidth,
        _barHeight
    ];

    _defenderBarControl ctrlShow true;
    _defenderBarControl ctrlCommit 0;

    _attackerBarControl ctrlSetBackgroundColor _attackerColor;
    _attackerBarControl ctrlSetPosition [
        _barX,
        _rowY + _barOffsetY,
        _attackerBarWidth,
        _barHeight
    ];

    _attackerBarControl ctrlShow (_attackerBarWidth > 0);
    _attackerBarControl ctrlCommit 0;

    _progressPercentControl ctrlSetFontHeight _barHeight;
    _progressPercentControl ctrlSetStructuredText parseText format [
        "<t align='center'>%1</t>",
        _captureProgressDisplay
    ];

    _progressPercentControl ctrlSetPosition [
        _percentX,
        _rowY + _barOffsetY,
        _percentWidth,
        _barHeight
    ];

    _progressPercentControl ctrlShow true;
    _progressPercentControl ctrlCommit 0;

    _progressDirectionControl ctrlSetFontHeight _barHeight;
    _progressDirectionControl ctrlSetStructuredText parseText format [
        "<t align='center'>%1</t>",
        _captureProgressDirection
    ];

    private _directionX = switch (_captureProgressDirectionSide) do {
        case "left": { _directionLeftX };
        case "right": { _directionRightX };
        default { _directionRightX };
    };

    _progressDirectionControl ctrlSetPosition [
        _directionX,
        _rowY + _barOffsetY,
        _directionWidth,
        _barHeight
    ];

    _progressDirectionControl ctrlShow (_captureProgressDirectionSide != "");
    _progressDirectionControl ctrlCommit 0;
} forEach _sectorCaptureList;

{
    _x params [
        "_capTextControl",
        "_sectorNameControl",
        "_defenderBarControl",
        "_attackerBarControl",
        "_progressPercentControl",
        "_progressDirectionControl"
    ];

    private _shouldShow = _forEachIndex < _captureSectorCount;

    _capTextControl ctrlShow _shouldShow;
    _sectorNameControl ctrlShow _shouldShow;
    _defenderBarControl ctrlShow _shouldShow;
    _attackerBarControl ctrlShow _shouldShow;
    _progressPercentControl ctrlShow _shouldShow;
    _progressDirectionControl ctrlShow _shouldShow;
} forEach _captureRowControls;

_display setVariable ["WL2_captureRowControls", _captureRowControls];

if (_captureSectorCount > 0) then {
    private _bottomGap = if (_showVote) then {
        _captureVoteGap
    } else {
        0
    };

    _titleHeight + (_captureSectorCount * _rowHeight) + _bottomGap
} else {
    0
};