#include "includes.inc"
params ["_display"];
_display setVariable ["TUT_closed", true];
{
    if (_x >= 0) then {
        stopSound _x;
    };
} forEach (_display getVariable ["TUT_sounds", []]);
_display setVariable ["TUT_sounds", []];

private _definition = _display getVariable ["TUT_definition", createHashMap];
[_display] call (_definition getOrDefault ["cleanup", {}]);

{
    private _map = _display displayCtrl _x;
    if (!isNull _map) then {
        _map ctrlRemoveAllEventHandlers "Draw";
        ctrlMapAnimClear _map;
    };
} forEach [TUT_MAP_IDC, TUT_CANVAS_IDC];

private _tutorialDisplay = uiNamespace getVariable ["TUT_display", displayNull];
if (_tutorialDisplay isEqualTo _display) then {
    uiNamespace setVariable ["TUT_display", displayNull];
};
