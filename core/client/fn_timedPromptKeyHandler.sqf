#include "includes.inc"
params ["_display", "_key", "_shift", "_ctrl", "_alt"];

private _display = uiNamespace getVariable ["RscWLPromptDisplay", displayNull];
if (isNull _display) exitWith {};

private _isLeftPressed = _key in actionKeys "LeanLeft";
private _isRightPressed = _key in actionKeys "LeanRight";

if (_isLeftPressed) then {
    _display setVariable ["WL2_isLeftPressed", true];
};
if (_isRightPressed) then {
    _display setVariable ["WL2_isRightPressed", true];
};

if (_isLeftPressed || _isRightPressed) then {
    true;
};