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

private _shouldShowCapture = _captureSectorCount > 0;

if (!isNull _captureTitleControl) then {
    _captureTitleControl ctrlSetStructuredText parseText "<t align='center'>CAPTURE PROGRESS</t>";
    _captureTitleControl ctrlSetPosition [
        WL_PANEL_X,
        WL_PANEL_PAD_TOP,
        WL_PANEL_W,
        WL_PANEL_CAP_TITLE
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
        if (_value - round _value < 0.01) then {
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
        "_sectorNameDisplay",
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

    private _rowY = WL_PANEL_CAP_ROW_Y + (_forEachIndex * WL_PANEL_CAP_ROW_H);

    private _attackerColor = [_capturingTeam] call _sideColor;
    private _defenderColor = [_defendingTeam] call _sideColor;

    private _progress = ((_captureProgressPercent / 100) max 0) min 1;
    private _attackerBarWidth = WL_PANEL_CAP_BAR_W * _progress;

    private _attackerCapDisplay = [_capturingTeamCap] call _formatCap;
    private _defenderCapDisplay = [_defendingTeamCap] call _formatCap;

    _capTextControl ctrlSetStructuredText parseText format [
        "<t align='left'>%1</t><t align='right'>%2</t>",
        _attackerCapDisplay,
        _defenderCapDisplay
    ];

    _capTextControl ctrlSetPosition [
        WL_PANEL_CAP_ROW_X,
        _rowY,
        WL_PANEL_CAP_ROW_W,
        WL_PANEL_CAP_NAME_H
    ];

    _capTextControl ctrlShow true;
    _capTextControl ctrlCommit 0;

    _sectorNameControl ctrlSetStructuredText parseText format [
        "<t align='center'>%1</t>",
        toUpper _sectorNameDisplay
    ];

    _sectorNameControl ctrlSetPosition [
        WL_PANEL_CAP_ROW_X,
        _rowY,
        WL_PANEL_CAP_ROW_W,
        WL_PANEL_CAP_NAME_H
    ];

    _sectorNameControl ctrlShow true;
    _sectorNameControl ctrlCommit 0;

    _defenderBarControl ctrlSetBackgroundColor _defenderColor;
    _defenderBarControl ctrlSetPosition [
        WL_PANEL_CAP_BAR_X,
        _rowY + WL_PANEL_CAP_BAR_OFFSET,
        WL_PANEL_CAP_BAR_W,
        WL_PANEL_CAP_BAR_H
    ];

    _defenderBarControl ctrlShow true;
    _defenderBarControl ctrlCommit 0;

    _attackerBarControl ctrlSetBackgroundColor _attackerColor;
    _attackerBarControl ctrlSetPosition [
        WL_PANEL_CAP_BAR_X,
        _rowY + WL_PANEL_CAP_BAR_OFFSET,
        _attackerBarWidth,
        WL_PANEL_CAP_BAR_H
    ];

    _attackerBarControl ctrlShow (_attackerBarWidth > 0);
    _attackerBarControl ctrlCommit 0;

    _progressPercentControl ctrlSetFontHeight WL_PANEL_CAP_BAR_H;
    _progressPercentControl ctrlSetStructuredText parseText format [
        "<t align='center' shadow='0'>%1</t>",
        _captureProgressDisplay
    ];

    _progressPercentControl ctrlSetPosition [
        WL_PANEL_CAP_PERCENT_X,
        _rowY + WL_PANEL_CAP_BAR_OFFSET,
        WL_PANEL_CAP_PERCENT_W,
        WL_PANEL_CAP_BAR_H
    ];

    _progressPercentControl ctrlShow true;
    _progressPercentControl ctrlCommit 0;

    _progressDirectionControl ctrlSetFontHeight WL_PANEL_CAP_BAR_H;
    _progressDirectionControl ctrlSetStructuredText parseText format [
        "<t align='center' shadow='0'>%1</t>",
        _captureProgressDirection
    ];

    private _directionX = switch (_captureProgressDirectionSide) do {
        case "left": { WL_PANEL_CAP_DIR_LEFT };
        case "right": { WL_PANEL_CAP_DIR_RIGHT };
        default { WL_PANEL_CAP_DIR_RIGHT };
    };

    _progressDirectionControl ctrlSetPosition [
        _directionX,
        _rowY + WL_PANEL_CAP_BAR_OFFSET,
        WL_PANEL_CAP_DIR_W,
        WL_PANEL_CAP_BAR_H
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
        WL_PANEL_GAP
    } else {
        0
    };

    WL_PANEL_PAD_TOP + WL_PANEL_CAP_TITLE + (_captureSectorCount * WL_PANEL_CAP_ROW_H) + _bottomGap
} else {
    0
};