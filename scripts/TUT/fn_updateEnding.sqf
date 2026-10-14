#include "includes.inc"
params ["_display"];
private _elapsed = diag_tickTime - (_display getVariable ["TUT_sceneStart", diag_tickTime]);
private _step = _display getVariable ["TUT_endingStep", 0];
private _logo = _display displayCtrl TUT_ENDLOGO_IDC;
private _duration = _display getVariable ["TUT_sceneDuration", 6];
private _flashAt = _display getVariable ["TUT_endingFlashAt", 3];
private _logoFadeAt = (_display getVariable ["TUT_speechEnd", 3.55]) max (_flashAt + 0.45);
private _fadeAt = _duration - 1.3;

if (_elapsed >= _flashAt && _step < 1) then {
    private _black = _display displayCtrl TUT_BLACKOUT_IDC;
    private _caption = _display displayCtrl TUT_CAPTION_IDC;
    private _visible = [_black, _logo, _caption,
        _display displayCtrl TUT_SKIP_BACKGROUND_IDC,
        _display displayCtrl TUT_SKIP_FILL_IDC,
        _display displayCtrl TUT_SKIP_IDC
    ];
    {
        if !(_x in _visible) then {
            _x ctrlShow false;
        };
    } forEach allControls _display;
    _black ctrlShow true;
    _black ctrlSetFade 0;
    _black ctrlCommit 0;
    _logo ctrlShow true;
    _logo ctrlSetFade 1;
    _logo ctrlCommit 0;
    _logo ctrlSetFade 0;
    _logo ctrlCommit 0.12;
    _step = 1;
};

if (_elapsed >= _logoFadeAt && _step < 2) then {
    _logo ctrlSetFade 1;
    _logo ctrlCommit (0.6 min (_fadeAt - _logoFadeAt));
    _step = 2;
};

if (_elapsed >= _fadeAt && _step < 3) then {
    {
        _x ctrlSetFade 1;
        _x ctrlCommit 1.3;
    } forEach allControls _display;
    _step = 3;
};

_display setVariable ["TUT_endingStep", _step];
