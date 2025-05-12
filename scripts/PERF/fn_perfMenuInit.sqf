#include "constants.inc"

private _display = findDisplay PERF_DISPLAY;
if (isNull _display) then {
    _display = createDialog ["PERF_Menu", true];
};

disableSerialization;

private _closeButton = _display displayCtrl PERF_CLOSE_BUTTON;
_closeButton ctrlAddEventHandler ["ButtonClick", {
    closeDialog 0;
}];

private _errorText = _display displayCtrl PERF_ERROR_TEXT;
private _clearFrameButton = _display displayCtrl PERF_LOWFPS_CLEAR_BUTTON;
private _captureButton = _display displayCtrl PERF_CAPTURE_BUTTON;
private _captureEntry = _display displayCtrl PERF_CAPTURE_ENTRY_TEXT;
private _lowfpsDisplay = _display displayCtrl PERF_LOWFPS_TEXT;

private _buildType = productVersion # 4;
if (_buildType != "Profile") exitWith {
    _errorText ctrlSetText "Profile build not detected. This feature is only available for Profiling builds.";
    _clearFrameButton ctrlShow false;
    _captureButton ctrlShow false;
    _captureEntry ctrlShow false;
    _lowfpsDisplay ctrlShow false;
};

uiNamespace setVariable ["PERF_longestFrame", 0];
[_display] spawn {
    params ["_display"];
    private _lowfpsDisplay = _display displayCtrl PERF_LOWFPS_TEXT;
    while {!isNull _display} do {
        private _longestFrame = uiNamespace getVariable ["PERF_longestFrame", 0];
        _longestFrame = _longestFrame max (1000 / diag_fps);
        uiNamespace setVariable ["PERF_longestFrame", _longestFrame];
        _lowfpsDisplay ctrlSetText format ["Longest Frame: %1ms", _longestFrame toFixed 3];
        sleep 0.001;
    };
};

_clearFrameButton ctrlAddEventHandler ["ButtonClick", {
    uiNamespace setVariable ["PERF_longestFrame", 0];
}];

_captureButton ctrlAddEventHandler ["ButtonClick", {
    params ["_control"];
    private _display = ctrlParent _control;
    private _captureEntry = _display displayCtrl PERF_CAPTURE_ENTRY_TEXT;
    private _captureFrameTime = parseNumber (ctrlText _captureEntry);
    if (_captureFrameTime <= 0) exitWith {
        private _errorText = _display displayCtrl PERF_ERROR_TEXT;
        _errorText ctrlSetText "Invalid frame time. Please enter a number.";
    };
    _captureFrameTime = format ["%1ms", _captureFrameTime];

    systemChat format ["Capture frame slower than: %1", _captureFrameTime];
    closeDialog 0;
#if __A3_PROFILING__
    diag_captureSlowFrame ["total", _captureFrameTime];
#endif
}];
