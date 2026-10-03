#include "includes.inc"
params ["_display"];
_display setVariable ["INTRO_closed", true];
{
    private _soundId = _display getVariable [_x, -1];
    if (_soundId >= 0) then {
        stopSound _soundId;
    };
    _display setVariable [_x, -1];
} forEach ["INTRO_narrationId", "INTRO_soundtrackId"];

[_display, "hide"] call INTRO_fnc_menuScene;

private _map = _display displayCtrl INTRO_MAP_IDC;
if (!isNull _map) then {
    _map ctrlRemoveAllEventHandlers "Draw";
    ctrlMapAnimClear _map;
};

private _introDisplay = uiNamespace getVariable ["INTRO_display", displayNull];
if (_introDisplay isEqualTo _display) then {
    uiNamespace setVariable ["INTRO_display", displayNull];
};