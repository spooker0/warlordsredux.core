#include "includes.inc"
params ["_direction"];

private _display = uiNamespace getVariable ["RscWLScoreboardMenu", displayNull];
if (isNull _display) exitWith { false };

private _content = _display displayCtrl WL_SCOREBOARD_CONTENT_ID;
if (isNull _content) exitWith { true };

if (_direction != 0) then {
    private _frameVariable = if (_direction < 0) then {
        "WL2_scoreboardScrollUpFrame"
    } else {
        "WL2_scoreboardScrollDownFrame"
    };

    private _lastFrame = _display getVariable [_frameVariable, -1];
    if (_lastFrame == diag_frameNo) then {
        _direction = 0;
    } else {
        _display setVariable [_frameVariable, diag_frameNo];
    };
};

private _scrollOffset = _display getVariable ["WL2_scoreboardScrollOffset", 0];
private _maxScroll = _display getVariable ["WL2_scoreboardMaxScroll", 0];
private _scrollStep = _direction * WL_SCOREBOARD_SCROLL_STEP;
_scrollOffset = (_scrollOffset + _scrollStep) max 0 min _maxScroll;

_display setVariable ["WL2_scoreboardScrollOffset", _scrollOffset];

private _position = ctrlPosition _content;
_position set [1, -_scrollOffset];

_content ctrlSetPosition _position;
_content ctrlCommit 0;

true;
