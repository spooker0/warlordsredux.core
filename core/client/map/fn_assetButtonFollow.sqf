#include "includes.inc"
params ["_asset"];

private _followState = _asset getVariable ["WL2_aiFollow", true];
private _followColor = if (_followState) then {
    "#00ff00"
} else {
    "#ff0000"
};
private _followText = if (_followState) then {
    "Yes"
} else {
    "No"
};

private _buttonText = format ["<t color='%1'>Fast travel with me: %2</t>", _followColor, _followText];
_buttonText;