#include "includes.inc"
params ["_asset"];

private _radarRotation = _asset getVariable ["radarRotation", false];
private _radarColor = if (_radarRotation) then {
    "#00ff00"
} else {
    "#ff0000"
};
private _radarOnText = if (_radarRotation) then {
    "Rotating"
} else {
    "Stopped"
};

private _buttonText = format ["<t color='%1'>Radar rotate: %2</t>", _radarColor, _radarOnText];
_buttonText;