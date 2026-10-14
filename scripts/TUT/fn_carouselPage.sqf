#include "includes.inc"
params ["_display", "_step", ["_finish", false]];

private _closed = _display getVariable ["TUT_closed", true];
if (isNull _display || _closed) exitWith {};

private _definition = _display getVariable ["TUT_definition", createHashMap];
private _scenes = _definition getOrDefault ["scenes", []];
private _current = _display getVariable ["TUT_scene", 0];
private _scene = _current + _step;
if (_scene < 1) exitWith {};
if (_scene > count _scenes) exitWith {
    if (_finish) then {
        _display closeDisplay 1;
        [] call (_definition getOrDefault ["completed", {}]);
    };
};

{
    if (_x >= 0) then {
        stopSound _x;
    };
} forEach (_display getVariable ["TUT_sounds", []]);
_display setVariable ["TUT_sounds", []];
_display setVariable ["TUT_soundCues", createHashMap];
{
    _x ctrlShow false;
} forEach (_display getVariable ["TUT_labelPool", []]);

(_scenes # (_scene - 1)) params ["_duration", "_caption"];
_display setVariable ["TUT_scene", _scene];
_display setVariable ["TUT_sceneStart", diag_tickTime];
_display setVariable ["TUT_sceneDuration", _duration max 0.1];
_display setVariable ["TUT_elapsed", 0];
_display setVariable ["TUT_cycle", 0];

private _captionControl = _display displayCtrl TUT_CAPTION_IDC;
_captionControl ctrlSetStructuredText parseText format ["<t align='center'>%1</t>", _caption];
private _captionHeight = ctrlTextHeight _captionControl + safeZoneH * 0.006;
_captionControl ctrlSetPositionY (safeZoneY + safeZoneH * 0.835 - _captionHeight);
_captionControl ctrlSetPositionH _captionHeight;
_captionControl ctrlCommit 0;

(_display displayCtrl TUT_PROGRESS_IDC) progressSetPosition (_scene / count _scenes);
{
    _x params ["_buttonIdc", "_iconIdc", "_enabled"];
    (_display displayCtrl _buttonIdc) ctrlEnable _enabled;
    private _fade = if (_enabled) then {
        0;
    } else {
        0.65;
    };
    private _icon = _display displayCtrl _iconIdc;
    _icon ctrlSetFade _fade;
    _icon ctrlCommit 0;
} forEach [
    [TUT_PREVIOUS_IDC, TUT_PREVIOUS_ICON_IDC, _scene > 1],
    [TUT_NEXT_IDC, TUT_NEXT_ICON_IDC, true]
];

private _nextText = if (_scene == count _scenes) then {
    localize "STR_WL_tutorialDone";
} else {
    localize "STR_WL_next";
};
(_display displayCtrl TUT_NEXT_IDC) ctrlSetTooltip _nextText;
private _next = _display displayCtrl TUT_CONTINUE_IDC;
_next ctrlSetText toUpper _nextText;
_next ctrlSetTooltip _nextText;
ctrlSetFocus _next;

private _map = _display displayCtrl TUT_MAP_IDC;
ctrlMapAnimClear _map;
[_display, _scene, _duration, 1] call (_definition getOrDefault ["enter", {}]);
ctrlMapAnimCommit _map;
[_display, _scene, 0, _duration] call (_definition getOrDefault ["update", {}]);
