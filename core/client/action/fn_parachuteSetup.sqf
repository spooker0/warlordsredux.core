#include "includes.inc"
params ["_unit"];

private _parachuteActionId = _unit addAction [
    "<t color='#00ff00'>Open Parachute</t>",
    WL2_fnc_parachuteAction,
    [],
    100
];

private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];
private _parachuteAutoDeployHeight = _settingsMap getOrDefault ["parachuteAutoDeployHeight", 100];
waitUntil {
    uiSleep 0.01;
    private _altitude = (_unit modelToWorld [0, 0, 0]) # 2;
    _altitude < _parachuteAutoDeployHeight ||
    isTouchingGround (vehicle _unit) ||
    !alive _unit || vehicle _unit != _unit;
};

_unit removeAction _parachuteActionId;

if (alive _unit && vehicle _unit == _unit) then {
    [objNull, _unit, -1, []] call WL2_fnc_parachuteAction;
};