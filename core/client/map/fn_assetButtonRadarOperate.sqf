#include "includes.inc"
params ["_asset"];

private _radarOperation = _asset getVariable ["radarOperation", false];
private _radarColor = if (_radarOperation) then {
    "green"
} else {
    "red"
};
private _radarOnText = if (_radarOperation) then {
    "On"
} else {
    "Off"
};

private _buttonText = format ["<span class='%1'>Radar control: %2</span>", _radarColor, _radarOnText];
_buttonText;