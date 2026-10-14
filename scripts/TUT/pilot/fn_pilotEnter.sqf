#include "..\includes.inc"
params ["_display", "_scene"];

private _map = _display displayCtrl TUT_MAP_IDC;
private _canvas = _display displayCtrl TUT_CANVAS_IDC;
private _header = _display displayCtrl TUT_FLARE_HEADER_IDC;
private _launcher = _display getVariable ["TUT_launcher", [0, 0, 0]];
_map ctrlShow true;
_canvas ctrlShow false;
_header ctrlShow (_scene in [1, 2, 3]);

if !(_scene in [1, 2]) then {
    private _controls = _display getVariable ["TUT_flareControls", []];
    _controls = [_display, _header, _controls, []] call DIS_fnc_drawFlareDisplay;
    _display setVariable ["TUT_flareControls", _controls];
};

private _distance = _display getVariable ["TUT_launchDistance", 5000];
private _view = [_launcher vectorAdd [_distance / 2, 0, 0], [_distance + 1500, 2000], [0.5, 0.64]];
if (_scene in [3, 4, 5]) then {
    private _jet = _launcher vectorAdd [_distance, 0, 0];
    _view = [_jet, [_distance + 1500, 2000], [0.5, 0.5]];
};

if (_scene == 6) then {
    private _center = _display getVariable ["TUT_overviewCenter", _launcher];
    private _span = _display getVariable ["TUT_overviewSpan", [15000, 11000]];
    _view = [_center, _span apply { _x / 0.8 }, [0.5, 0.44]];
};
_display setVariable ["TUT_mapView", _view];
_display setVariable ["TUT_mapNeedsFit", true];
