#include "includes.inc"
// A definition supplies scenes and enter/update/draw callbacks. All state belongs to this display.
// Scenes: [duration, caption, optional animation duration, speech end, logo ending time].
// State entries become TUT_<key> variables on the display.
// init/cleanup receive [display]; enter receives [display, scene, animation duration, time scale].
// update receives [display, scene, elapsed, duration]. draw receives [map]. completed receives [].
params [["_tutorial", "intro"]];

if (!hasInterface) exitWith {};
if (!canSuspend) exitWith {
    _this spawn TUT_fnc_play;
};
disableSerialization;

private _existingDisplay = uiNamespace getVariable ["TUT_display", displayNull];
if (!isNull _existingDisplay) exitWith {};
private _parent = findDisplay 46;
if (isNull _parent) exitWith {};

// New tutorials can register a name here, or pass their definition directly.
private _definition = if (_tutorial isEqualType createHashMap) then {
    _tutorial;
} else {
    switch (_tutorial) do {
        case "intro": { call TUT_fnc_introData };
        default { createHashMap };
    };
};
private _scenes = _definition getOrDefault ["scenes", []];
if (count _scenes == 0) exitWith {};

private _display = _parent createDisplay "TUT_Display";
if (isNull _display) exitWith {};
uiNamespace setVariable ["TUT_display", _display];
_display setVariable ["TUT_closed", false];
_display setVariable ["TUT_definition", _definition];

private _state = _definition getOrDefault ["state", createHashMap];
{
    _display setVariable ["TUT_" + _x, _y];
} forEach _state;

private _holdToSkip = _definition getOrDefault ["holdToSkip", false];
_display setVariable ["TUT_holdToSkip", _holdToSkip];
_display setVariable ["TUT_skipBindings", (actionKeysEx "Gear") select {
    _x params ["_main", "_combo"];
    (_main # 1) in ["KEYBOARD", "MOUSE_BUTTON"] && {
        count _combo == 0 || { (_combo # 1) in ["KEYBOARD", "MOUSE_BUTTON"] }
    };
}];
_display setVariable ["TUT_skipKeys", []];
_display setVariable ["TUT_skipStart", -1];

_display displayAddEventHandler ["KeyDown", {
    params ["_display", "_key", "_shift", "_ctrl", "_alt"];
    [_display, "KEYBOARD", _key, true, [_shift, _ctrl, _alt]] call TUT_fnc_updateSkip;
    true;
}];
_display displayAddEventHandler ["KeyUp", {
    params ["_display", "_key", "_shift", "_ctrl", "_alt"];
    [_display, "KEYBOARD", _key, false, [_shift, _ctrl, _alt]] call TUT_fnc_updateSkip;
    true;
}];
_display displayAddEventHandler ["MouseButtonDown", {
    params ["_display", "_button", "", "", "_shift", "_ctrl", "_alt"];
    [_display, "MOUSE_BUTTON", _button, true, [_shift, _ctrl, _alt]] call TUT_fnc_updateSkip;
    true;
}];
_display displayAddEventHandler ["MouseButtonUp", {
    params ["_display", "_button", "", "", "_shift", "_ctrl", "_alt"];
    [_display, "MOUSE_BUTTON", _button, false, [_shift, _ctrl, _alt]] call TUT_fnc_updateSkip;
    true;
}];

private _map = _display displayCtrl TUT_MAP_IDC;
private _canvas = _display displayCtrl TUT_CANVAS_IDC;
private _caption = _display displayCtrl TUT_CAPTION_IDC;
private _progress = _display displayCtrl TUT_PROGRESS_IDC;
private _sceneHeader = _display displayCtrl TUT_SCENE_IDC;
_sceneHeader ctrlSetStructuredText parseText (_definition getOrDefault ["header", toUpper localize "STR_WL_tutorial"]);
(_display displayCtrl TUT_BLACKOUT_IDC) ctrlShow false;
(_display displayCtrl TUT_ENDLOGO_IDC) ctrlShow false;
(_display displayCtrl TUT_FLARE_HEADER_IDC) ctrlShow false;

private _gearKey = ["Gear", localize "STR_WL_introGear"] call TUT_fnc_keyName;
private _skipText = if (_holdToSkip) then {
    format [localize "STR_WL_introSkip", _gearKey];
} else {
    "ESC - SKIP";
};
private _skip = _display displayCtrl TUT_SKIP_IDC;
_skip ctrlSetText _skipText;
private _skipWidth = ((_skipText getTextWidth ["RobotoCondensed", safeZoneH * 0.026]) + safeZoneW * 0.025) max (safeZoneW * 0.17);
private _skipLeft = safeZoneX + safeZoneW * 0.965 - _skipWidth;
{
    _x ctrlSetPositionX _skipLeft;
    _x ctrlSetPositionW _skipWidth;
    _x ctrlCommit 0;
} forEach [_skip, _display displayCtrl TUT_SKIP_FILL_IDC, _display displayCtrl TUT_SKIP_BACKGROUND_IDC];
_sceneHeader ctrlSetPositionW (_skipLeft - safeZoneX - safeZoneW * 0.065);
_sceneHeader ctrlCommit 0;
(_display displayCtrl TUT_SKIP_FILL_IDC) progressSetPosition 0;
(_display displayCtrl TUT_HOLD_IDC) ctrlSetText format [localize "STR_WL_introHold", _gearKey];

{
    _x ctrlEnable false;
    _x ctrlAddEventHandler ["Draw", {
        _this call TUT_fnc_drawMap;
    }];
} forEach [_map, _canvas];
// A second, terrain-free map provides the same drawing API for screen-space diagrams.
_canvas ctrlMapAnimAdd [0, 0.01, [-worldSize, -worldSize]];
ctrlMapAnimCommit _canvas;
_canvas ctrlShow false;

[_display] call (_definition getOrDefault ["init", {}]);

private _totalDuration = 0;
{
    _totalDuration = _totalDuration + (_x # 0);
} forEach _scenes;

private _overallStart = diag_tickTime;
private _narration = _definition getOrDefault ["narration", []];
if (count _narration > 0) then {
    [_display, "narration", _narration] call TUT_fnc_soundCue;
};
private _soundtrack = _definition getOrDefault ["soundtrack", ["a3\music_f_tank\maintheme_f_tank.ogg", 0.2, 1, false]];
if (count _soundtrack > 0) then {
    [_display, "soundtrack", _soundtrack] call TUT_fnc_soundCue;
};

private _completed = false;
private _started = _overallStart;
private _enter = _definition getOrDefault ["enter", {}];
private _update = _definition getOrDefault ["update", {}];

{
    private _closed = _display getVariable ["TUT_closed", true];
    if (isNull _display || _closed) then {
        break;
    };

    // duration, caption, original animation duration, speech end, optional logo ending
    _x params ["_duration", "_text", ["_animationDuration", 0], ["_speechEnd", 0], ["_endingAt", -1]];
    if (_animationDuration <= 0) then {
        _animationDuration = _duration;
    };
    private _scene = _forEachIndex + 1;
    private _timeScale = _duration / _animationDuration;
    _display setVariable ["TUT_scene", _scene];
    _display setVariable ["TUT_sceneStart", _started];
    _display setVariable ["TUT_sceneDuration", _duration];
    _display setVariable ["TUT_animationScale", 1 / _timeScale];
    _display setVariable ["TUT_speechEnd", _speechEnd];
    _display setVariable ["TUT_endingStep", 0];
    _display setVariable ["TUT_endingFlashAt", _endingAt];

    {
        _x ctrlShow false;
    } forEach (_display getVariable ["TUT_labelPool", []]);
    {
        (_display displayCtrl _x) ctrlShow false;
    } forEach [TUT_HOLD_IDC, TUT_LOGO_IDC, TUT_LOGO_BACKGROUND_IDC, TUT_CANVAS_IDC];
    _map ctrlShow true;
    ctrlMapAnimClear _map;

    _caption ctrlSetStructuredText parseText format ["<t align='center'>%1</t>", _text];
    private _captionHeight = (ctrlTextHeight _caption + safeZoneH * 0.008) max (safeZoneH * 0.078);
    _caption ctrlSetPositionY (safeZoneY + safeZoneH * 0.983 - _captionHeight);
    _caption ctrlSetPositionH _captionHeight;
    _caption ctrlCommit 0;
    _caption ctrlSetFade 1;
    _caption ctrlCommit 0;
    _caption ctrlSetFade 0;
    _caption ctrlCommit 0.25;

    [_display, _scene, _animationDuration, _timeScale] call _enter;
    ctrlMapAnimCommit _map;

    waitUntil {
        private _closed = _display getVariable ["TUT_closed", true];
        if (!isNull _display && !_closed) then {
            private _elapsed = (diag_tickTime - _started) max 0;
            _progress progressSetPosition (((diag_tickTime - _overallStart) / _totalDuration) min 1);
            [_display, _scene, _elapsed, _duration] call _update;
            if (_endingAt >= 0) then {
                [_display] call TUT_fnc_updateEnding;
            };
            [_display] call TUT_fnc_updateSkip;
        };

        uiSleep 0.01;
        _closed = _display getVariable ["TUT_closed", true];
        isNull _display || _closed || diag_tickTime >= _started + _duration;
    };

    _closed = _display getVariable ["TUT_closed", true];
    if (isNull _display || _closed) then {
        break;
    };

    _started = _started + _duration;
    _completed = _scene == count _scenes;
} forEach _scenes;

if (!isNull _display) then {
    _display closeDisplay 1;
};
if (_completed && !isNull (findDisplay 46)) then {
    [] call (_definition getOrDefault ["completed", {}]);
};
