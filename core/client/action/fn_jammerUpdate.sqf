#include "includes.inc"
params ["_asset", "_actionID"];

private _isActive = _asset getVariable ["WL_ewNetActive", false];
private _isActivating = _asset getVariable ["WL_ewNetActivating", false];
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

if (isServer) then {
    private _rotationState = _asset animationSourcePhase "Radar_Rotation";
    if (_isActive || _isActivating) then {
        _asset animateSource ["Radar_Rotation", _rotationState + 1, 1];
    } else {
        _asset animateSource ["Radar_Rotation", _rotationState, 1];
    };
};

_asset setUserActionText [_actionID, format ["<t color = '%1'>%2</t>", _actionColor, _actionText]];