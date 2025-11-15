#include "includes.inc"
params ["_asset"];

private _radarRotation = _asset getVariable ["radarRotation", false];
private _radarColor = if (_radarRotation) then {
    "green"
} else {
    "red"
};
private _radarOnText = if (_radarRotation) then {
    "Rotating"
} else {
    "Stopped"
};

private _buttonText = format ["<span class='%1'>Radar rotate: %2</span>", _radarColor, _radarOnText];
_buttonText;