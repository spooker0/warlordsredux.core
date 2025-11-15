#include "includes.inc"
params ["_asset"];

private _jammerActivated = _asset getVariable ["WL_ewNetActive", false];
private _jammerActivating = _asset getVariable ["WL_ewNetActivating", false];
private _jammerColor = if (_jammerActivated) then {
    "green"
} else {
    if (_jammerActivating) then {
        "cyan"
    } else {
        "red"
    };
};
private _jammerText = if (_jammerActivated) then {
    "On"
} else {
    if (_jammerActivating) then {
        "Activating"
    } else {
        "Off"
    };
};
private _buttonText = format ["<span class='%1'>EW network: %2</span>", _jammerColor, _jammerText];
_buttonText;