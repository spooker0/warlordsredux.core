#include "includes.inc"
params ["_control"];
if (isNull _control) exitWith {};

private _target = _control getVariable ["SPEC_target", objNull];
if (isNull _target) exitWith {};

playSoundUI ["a3\ui_f\data\sound\rsclistbox\soundselect.wss", 0.5];

[_target] call SPEC_fnc_spectatorSelectTarget;

private _display = ctrlParent _control;
if (!isNull _display) then {
    _display closeDisplay 2;
};