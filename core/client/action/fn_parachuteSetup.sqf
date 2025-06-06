#include "includes.inc"
params ["_unit", "_actionId"];

private _parachuteActionId = _unit addAction [
    "<t color='#00ff00'>Open Parachute</t>",
    WL2_fnc_parachuteAction,
    [],
    100
];

private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];
private _parachuteAutoDeployHeight = _settingsMap getOrDefault ["parachuteAutoDeployHeight", 100];
waitUntil {
    sleep 0.01;
    (getPosATL _unit # 2) < _parachuteAutoDeployHeight ||
    (getPosASL _unit # 2) < _parachuteAutoDeployHeight ||
    isTouchingGround (vehicle _unit) ||
    !alive _unit || vehicle _unit != _unit;
};

_unit removeAction _parachuteActionId;

if (alive _unit && vehicle _unit == _unit) then {
    [objNull, _unit, -1, []] call WL2_fnc_parachuteAction;
};