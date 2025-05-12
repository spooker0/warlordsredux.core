params ["_asset", "_actionID"];

private _isActive = _asset getVariable ["WL_ewNetActive", false] && isEngineOn _asset;
private _isActivating = _asset getVariable ["WL_ewNetActivating", false] && isEngineOn _asset;
private _actionColor = if (_isActive) then {
    "#4b51ff";
} else {
    "#ff4b4b";
};

private _actionText = if (_isActive) then {
    "EW NETWORK: ON";
} else {
    if (_isActivating) then {
        "EW NETWORK: ACTIVATING...";
    } else {
        "EW NETWORK: OFF";
    };
};

if (!_isActive && !_isActivating) then {
    _asset setFuelConsumptionCoef 1;
} else {
    _asset setFuelConsumptionCoef 5;
};

if (isServer) then {
    private _rotationState = _asset animationSourcePhase "Radar_Rotation";
    if (_isActive || _isActivating) then {
        _asset animateSource ["Radar_Rotation", _rotationState + 1, 1];
    } else {
        _asset animateSource ["Radar_Rotation", _rotationState, 1];
    };
};

_asset setUserActionText [_actionID, format ["<t color = '%1'>%2</t>", _actionColor, _actionText]];