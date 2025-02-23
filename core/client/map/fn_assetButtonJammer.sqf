params ["_asset"];

private _jammerActivated = _asset getVariable ["WL_ewNetActive", false] && isEngineOn _asset;
private _jammerActivating = _asset getVariable ["WL_ewNetActivating", false] && isEngineOn _asset;
private _jammerColor = if (_jammerActivated) then {
    "#4bff58"
} else {
    if (_jammerActivating) then {
        "#4b51ff"
    } else {
        "#ff4b4b"
    };
};
private _jammerText = if (_jammerActivated) then {
    "ON"
} else {
    if (_jammerActivating) then {
        "ACTIVATING"
    } else {
        "OFF"
    };
};
private _buttonText = format ["EW NETWORK: <t color='%1'>%2</t>", _jammerColor, _jammerText];
_buttonText;