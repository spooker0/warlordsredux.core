#include "..\includes.inc"
params ["_display", "_scene", "_elapsed", "_duration"];

if !(_scene in [1, 2, 3]) exitWith {};

private _rows = [];
if (_scene in [1, 2]) then {
    private _minimum = _display getVariable ["TUT_spartanMin", 0];
    private _maximum = _display getVariable ["TUT_spartanMax", 0];
    private _launchDistance = _display getVariable ["TUT_launchDistance", 5000];
    private _pauseDistance = _display getVariable ["TUT_pauseDistance", 3000];
    private _launcher = _display getVariable ["TUT_launcher", [0, 0, 0]];
    private _jet = _launcher vectorAdd [_launchDistance, 0, 0];
    private _distance = linearConversion [0, 4, _elapsed, _launchDistance, _pauseDistance, true];
    private _turn = 0;
    if (_scene == 2) then {
        _distance = linearConversion [0, _duration - 2, _elapsed, _pauseDistance, 1000, true];
        _turn = if (_elapsed < 5) then {
            linearConversion [1, 4, _elapsed, 0, 90, true];
        } else {
            linearConversion [6, 9, _elapsed, 90, 0, true];
        };
    };

    // At full tutorial airspeed, perpendicular effectiveness is sin(relative angle).
    private _effectiveness = sin _turn;
    _minimum = linearConversion [0, 1, _effectiveness, _minimum, 0, true];
    private _inWindow = _minimum < _maximum && _distance >= _minimum && _distance <= _maximum;
    private _window = [_minimum, (_minimum + _maximum) / 2, _maximum, _distance, _inWindow];
    _rows pushBack [localize "STR_WL_pilotSpartan", _window];
    _display setVariable ["TUT_jetPosition", _jet];
    _display setVariable ["TUT_jetHeading", 270 + _turn];
    _display setVariable ["TUT_missilePosition", _jet vectorAdd [-_distance, 0, 0]];
};

private _flares = _display getVariable ["TUT_pilotFlares", [15, 6, 5]];
_flares params ["_capacity", "_reloadDuration", "_jamDuration"];
private _singlesStart = _display getVariable ["TUT_singlesStart", 4.04];
private _singles = _scene == 3 && _elapsed >= _singlesStart;
private _bursts = _capacity;
private _reload = 0;
private _jam = 0;
if (_scene == 3) then {
    private _needsFit = _display getVariable ["TUT_mapNeedsFit", true];
    if (!_needsFit) then {
        private _map = _display displayCtrl TUT_MAP_IDC;
        private _mapView = _display getVariable ["TUT_mapView", [[0, 0, 0], [6500, 2000], [0.5, 0.5]]];
        private _started = _display getVariable ["TUT_sceneStart", diag_tickTime];
        // Moving the camera north scrolls the terrain down beneath the fixed jet icon.
        private _position = (_mapView # 0) vectorAdd [0, (diag_tickTime - _started) * 50, 0];
        _map ctrlMapAnimAdd [0, ctrlMapScale _map, _position];
        ctrlMapAnimCommit _map;
    };

    private _fireAt = if (_singles) then {
        _singlesStart;
    } else {
        1;
    };
    private _interval = if (_singles) then {
        0.75;
    } else {
        0.06;
    };
    _display setVariable ["TUT_flareEmission", [_fireAt, _interval]];

    if (_elapsed >= 1) then {
        _bursts = _capacity - 1;
        private _reloadAt = if (_singles) then {
            _singlesStart;
        } else {
            1;
        };
        private _multiplier = if (_singles) then {
            3;
        } else {
            1;
        };
        _reload = (_multiplier * _reloadDuration - (_elapsed - _reloadAt)) max 0;
        _jam = (_multiplier * _jamDuration - (_elapsed - _reloadAt)) max 0;
        if (_singles) then {
            _bursts = _bursts - 1;
        };
    };
};
if (_singles) then {
    [_display, "mode", ["a3\sounds_f_orange\arsenal\explosives\minedispenser\minedispenser_mine_trigger_01.wss", 1]] call TUT_fnc_soundCue;
};

private _launchKey = _display getVariable ["TUT_launchKey", ""];
private _modeKey = _display getVariable ["TUT_modeKey", ""];
private _header = _display displayCtrl TUT_FLARE_HEADER_IDC;
private _text = [_bursts, _capacity, _reload, _jam, _singles, _launchKey, _modeKey] call DIS_fnc_flareHeaderText;
_header ctrlSetStructuredText parseText _text;
_header ctrlSetPositionH (ctrlTextHeight _header + safeZoneH * 0.006);
_header ctrlCommit 0;

private _controls = _display getVariable ["TUT_flareControls", []];
_controls = [_display, _header, _controls, _rows, safeZoneH * 1.25] call DIS_fnc_drawFlareDisplay;
_display setVariable ["TUT_flareControls", _controls];
