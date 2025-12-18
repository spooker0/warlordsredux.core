#include "includes.inc"
params ["_asset"];

private _radarOperation = _asset getVariable ["radarOperation", false];
private _radarColor = if (_radarOperation) then {
    "#00ff00"
} else {
    "#ff0000"
};
private _radarOnText = if (_radarOperation) then {
    "On"
} else {
    "Off"
};

private _buttonText = format ["<t color='%1'>Radar control: %2</t>", _radarColor, _radarOnText];
_buttonText;