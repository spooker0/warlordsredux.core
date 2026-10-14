#include "includes.inc"
// Carousel definitions use [loop duration, caption] scenes and the shared TUT callbacks.
params [["_tutorial", "pilot"]];

if (!hasInterface) exitWith {};
if (!canSuspend) exitWith {
    _this spawn TUT_fnc_carousel;
};
disableSerialization;

private _existingDisplay = uiNamespace getVariable ["TUT_display", displayNull];
if (!isNull _existingDisplay) exitWith {};
private _parent = findDisplay 46;
if (isNull _parent) exitWith {};

private _definition = if (_tutorial isEqualType createHashMap) then {
    _tutorial;
} else {
    switch (_tutorial) do {
        case "pilot": { call TUT_fnc_pilotData };
        default { createHashMap };
    };
};
private _scenes = _definition getOrDefault ["scenes", []];
if (count _scenes == 0) exitWith {};

private _display = _parent createDisplay "TUT_Carousel";
if (isNull _display) exitWith {};
uiNamespace setVariable ["TUT_display", _display];
_display setVariable ["TUT_closed", false];
_display setVariable ["TUT_definition", _definition];
_display setVariable ["TUT_scene", 0];

private _state = _definition getOrDefault ["state", createHashMap];
{
    _display setVariable ["TUT_" + _x, _y];
} forEach _state;

(_display displayCtrl TUT_SCENE_IDC) ctrlSetText (_definition getOrDefault ["header", toUpper localize "STR_WL_tutorial"]);
(_display displayCtrl TUT_FLARE_HEADER_IDC) ctrlShow false;
{
    private _map = _display displayCtrl _x;
    _map ctrlEnable false;
    _map ctrlMapSetPosition [];
    _map ctrlAddEventHandler ["Draw", {
        _this call TUT_fnc_drawMap;
    }];
} forEach [TUT_MAP_IDC, TUT_CANVAS_IDC];
private _canvas = _display displayCtrl TUT_CANVAS_IDC;
_canvas ctrlMapAnimAdd [0, 0.01, [-worldSize, -worldSize]];
ctrlMapAnimCommit _canvas;
_canvas ctrlShow false;

{
    _x params ["_idc", "_angle"];
    private _icon = _display displayCtrl _idc;
    _icon ctrlEnable false;
    _icon ctrlSetAngle [_angle, 0.5, 0.5];
} forEach [[TUT_PREVIOUS_ICON_IDC, 270], [TUT_NEXT_ICON_IDC, 90]];

(_display displayCtrl TUT_PREVIOUS_IDC) ctrlAddEventHandler ["ButtonClick", {
    [ctrlParent (_this # 0), -1] call TUT_fnc_carouselPage;
}];
(_display displayCtrl TUT_NEXT_IDC) ctrlAddEventHandler ["ButtonClick", {
    [ctrlParent (_this # 0), 1, true] call TUT_fnc_carouselPage;
}];
(_display displayCtrl TUT_CONTINUE_IDC) ctrlAddEventHandler ["ButtonClick", {
    [ctrlParent (_this # 0), 1, true] call TUT_fnc_carouselPage;
}];
_display displayAddEventHandler ["KeyDown", {
    params ["_display", "_key"];
    switch (_key) do {
        case 1: {
            _display closeDisplay 2;
            true;
        };
        case 203: {
            [_display, -1] call TUT_fnc_carouselPage;
            true;
        };
        case 205: {
            [_display, 1, true] call TUT_fnc_carouselPage;
            true;
        };
        // Leave normal button activation and focus traversal to the controls.
        default { !(_key in [15, 28, 57, 156]) };
    };
}];

[_display] call (_definition getOrDefault ["init", {}]);
[_display, 1] call TUT_fnc_carouselPage;
private _update = _definition getOrDefault ["update", {}];

while { !isNull _display } do {
    private _closed = _display getVariable ["TUT_closed", true];
    if (_closed) then {
        break;
    };

    private _scene = _display getVariable ["TUT_scene", 1];
    private _started = _display getVariable ["TUT_sceneStart", diag_tickTime];
    private _duration = _display getVariable ["TUT_sceneDuration", 1];
    private _elapsed = (diag_tickTime - _started) max 0;
    private _cycle = floor (_elapsed / _duration);
    private _previousCycle = _display getVariable ["TUT_cycle", 0];
    if (_cycle != _previousCycle) then {
        // Keep repeated audio cues bounded to the current animation loop.
        {
            if (_x >= 0) then {
                stopSound _x;
            };
        } forEach (_display getVariable ["TUT_sounds", []]);
        _display setVariable ["TUT_sounds", []];
        _display setVariable ["TUT_soundCues", createHashMap];
        _display setVariable ["TUT_cycle", _cycle];
    };

    _elapsed = _elapsed % _duration;
    _display setVariable ["TUT_elapsed", _elapsed];
    [_display, _scene, _elapsed, _duration] call _update;
    uiSleep 0.02;
};
