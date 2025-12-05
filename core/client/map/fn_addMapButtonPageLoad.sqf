#include "includes.inc"
params ["_texture"];
private _allButtonsData = _texture getVariable ["WL2_allButtonsData", []];

waitUntil {
    uiSleep 0.001;
    _allButtonsData = _texture getVariable ["WL2_allButtonsData", []];
    count _allButtonsData > 0 || isNull _texture
};

if (isNull _texture) exitWith {};

private _offsetX = _texture getVariable ["WL2_buttonsMenuOffsetX", 0];
private _offsetY = _texture getVariable ["WL2_buttonsMenuOffsetY", 0];

private _buttonsDataJSON = toJSON _allButtonsData;
private _script = format ["setButtons(%1, %2, %3);", _buttonsDataJSON, _offsetX, _offsetY];
_texture ctrlWebBrowserAction ["ExecJS", _script];