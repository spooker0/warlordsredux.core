#include "includes.inc"
params ["_asset"];

private _jammerActivated = _asset getVariable ["WL_ewNetActive", false];
private _jammerActivating = _asset getVariable ["WL_ewNetActivating", false];
private _jammerColor = if (_jammerActivated) then {
    "#00ff00"
} else {
    if (_jammerActivating) then {
        "#00ffff"
    } else {
        "#ff0000"
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
private _buttonText = format ["<t color='%1'>EW network: %2</t>", _jammerColor, _jammerText];
_buttonText;