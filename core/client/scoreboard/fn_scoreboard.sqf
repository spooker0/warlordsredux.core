#include "includes.inc"
disableSerialization;

private _display = uiNamespace getVariable ["RscWLScoreboardMenu", displayNull];
if (!isNull _display) exitWith {
    _display closeDisplay 1;
    uiNamespace setVariable ["RscWLScoreboardMenu", displayNull];
};

"scoreboard" cutRsc ["RscWLScoreboardMenu", "PLAIN", -1, true, true];
_display = uiNamespace getVariable ["RscWLScoreboardMenu", displayNull];
if (isNull _display) exitWith {};

private _icons = [
    "a3\modules_f_bootcamp\data\portraitbootcampstage.paa",
    "a3\ui_f\data\igui\cfg\weaponicons\srifle_ca.paa",
    "a3\static_f_sams\radar_system_01\data\ui\radar_system_01_picture_ca.paa",
    "a3\soft_f\mrap_01\data\ui\mrap_01_gmg_ca.paa",
    "a3\armor_f_tank\mbt_04\data\ui\mbt_04_command.paa",
    "a3\ui_f\data\gui\rsc\rscdisplaygarage\helicopter_ca.paa",
    "a3\ui_f\data\gui\rsc\rscdisplaygarage\plane_ca.paa",
    "a3\ui_f_curator\data\cfgmarkers\kia_ca.paa",
    "a3\modules_f_curator\data\portraitcuratoraddpoints_ca.paa"
];

private _flags = [
    "a3\ui_f\data\map\markers\flags\nato_ca.paa",
    "a3\ui_f\data\map\markers\flags\CSAT_ca.paa"
];

private _teamColors = [[0.4, 0.8, 1, 1], [1, 0.5, 0.5, 1]];
private _iconHeight = WL_SCOREBOARD_ICON_H;
private _iconWidth = _iconHeight * pixelW / pixelH;
private _iconY = (WL_SCOREBOARD_HEADER_H - _iconHeight) / 2;
private _flagHeight = WL_SCOREBOARD_FLAG_H;
private _flagWidth = _flagHeight * 1.5 * pixelW / pixelH;
private _flagY = WL_SCOREBOARD_Y - _flagHeight - WL_SCOREBOARD_FLAG_GAP;

private _summaries = [];
{
    private _teamIndex = _forEachIndex;
    private _teamColor = _teamColors # _teamIndex;
    private _panelX = WL_SCOREBOARD_X + _teamIndex * (WL_SCOREBOARD_PANEL_W + WL_SCOREBOARD_GAP);
    private _flagX = _panelX + (WL_SCOREBOARD_PANEL_W - _flagWidth) / 2;
    private _flagPosition = [_flagX, _flagY, _flagWidth, _flagHeight];
    private _flag = _display ctrlCreate ["RscPictureKeepAspect", -1];

    _flag ctrlSetPosition _flagPosition;
    _flag ctrlSetText _x;
    _flag ctrlCommit 0;

    private _headerPosition = [_panelX, WL_SCOREBOARD_Y, WL_SCOREBOARD_PANEL_W, WL_SCOREBOARD_HEADER_H];
    private _header = [_display, controlNull, _headerPosition, true] call WL2_fnc_scoreboardRow;
    private _separator = _header getVariable "WL2_scoreboardSeparator";
    private _headerCells = _header getVariable "WL2_scoreboardCells";

    _separator ctrlShow false;

    {
        _x ctrlShow false;
    } forEach _headerCells;

    {
        private _columnIndex = _forEachIndex + 1;
        private _cell = _headerCells # _columnIndex;
        private _cellPosition = ctrlPosition _cell;
        private _iconX = (_cellPosition # 0) + ((_cellPosition # 2) - _iconWidth) / 2;

        if (_columnIndex > 1) then {
            private _textRight = (_cellPosition # 0) + (_cellPosition # 2) - WL_SCOREBOARD_TEXT_MARGIN;
            _iconX = _textRight - _iconWidth;
        };

        private _iconPosition = [_iconX, _iconY, _iconWidth, _iconHeight];
        private _icon = _display ctrlCreate ["RscPictureKeepAspect", -1, _header];

        _icon ctrlSetPosition _iconPosition;
        _icon ctrlSetText _x;
        _icon ctrlCommit 0;
    } forEach _icons;

    private _summaryY = WL_SCOREBOARD_Y + WL_SCOREBOARD_HEADER_H;
    private _summaryPosition = [_panelX, _summaryY, WL_SCOREBOARD_PANEL_W, WL_SCOREBOARD_SUMMARY_H];
    private _summary = [_display, controlNull, _summaryPosition, true] call WL2_fnc_scoreboardRow;
    private _summaryBackground = _summary getVariable "WL2_scoreboardBackground";
    private _summaryCells = _summary getVariable "WL2_scoreboardCells";

    _summaryBackground ctrlSetBackgroundColor [0.25, 0.25, 0.25, 0.9];

    {
        _x ctrlSetTextColor _teamColor;
    } forEach _summaryCells;

    _summaries pushBack _summary;
} forEach _flags;

_display setVariable ["WL2_scoreboardSummaries", _summaries];
_display setVariable ["WL2_scoreboardRows", [[], []]];

[] remoteExec ["WL2_fnc_requestScoreboard", 2];

private _nextRequest = diag_tickTime + 10;
while { !isNull _display } do {
    if (diag_tickTime >= _nextRequest && !BIS_WL_missionEnd) then {
        [] remoteExec ["WL2_fnc_requestScoreboard", 2];
        _nextRequest = diag_tickTime + 10;
    };

    [_display] call WL2_fnc_scoreboardRender;
    uiSleep 0.5;
};
