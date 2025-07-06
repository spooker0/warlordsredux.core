#include "includes.inc"
params ["_up"];

private _display = uiNamespace getVariable ["RscWLScoreboardMenu", displayNull];
if (isNull _display) exitWith { false };

private _texture = _display displayCtrl 5502;

private _scrollAmount = if (_up) then {
    -100
} else {
    100
};

private _script = format ["scrollScoreboard(%1);", str _scrollAmount];
_texture ctrlWebBrowserAction ["ExecJS", _script];

true;