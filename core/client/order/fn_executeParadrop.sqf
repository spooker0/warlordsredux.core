#include "includes.inc"
params ["_position", "_direction", "_paradropper", "_playerVehicle"];

private _isControlling = driver _playerVehicle == player;
if (_isControlling) then {
    private _paradropKeyParams = ["PARADROP CONTROLS", [
        ["Move forward", "MoveForward"],
        ["Move backward", "MoveBack"],
        ["Move left", "TurnLeft"],
        ["Move right", "TurnRight"]
    ]];
    ["Paradrop", _paradropKeyParams] spawn WL2_fnc_showHint;
};

private _parachuteClass = switch (BIS_WL_playerSide) do {
    case west: {
        "B_Parachute_02_F";
    };
    case east: {
        "O_Parachute_02_F";
    };
    case independent: {
        "I_Parachute_02_F";
    };
};

if (_position # 2 < 200) then {
    _position set [2, 200];
};

_playerVehicle setDir _direction;
_playerVehicle setPosATL _position;

if (!isNull _paradropper) then {
    [player, "rewardTransport", _paradropper, [_playerVehicle]] remoteExec ["WL2_fnc_handleClientRequest", 2];
};

private _altitude = (getPosVisual _playerVehicle) # 2;
private _paradropMoveSpeed = 20;

while { _altitude > 200 } do {
    uiSleep 0.01;
    _playerVehicle setVectorUp [0, 0, 1];
    private _forward = if (_isControlling) then {
        inputAction "MoveForward" + inputAction "CarFastForward" - inputAction "MoveBack";
    } else {
        0;
    };
    private _side = if (_isControlling) then {
        inputAction "TurnRight" - inputAction "TurnLeft";
    } else {
        0;
    };
    _playerVehicle setVelocityModelSpace [_side * _paradropMoveSpeed, _forward * _paradropMoveSpeed, -150];

    _altitude = (getPosVisual _playerVehicle) # 2;
};

private _parachute = createVehicle [_parachuteClass, _playerVehicle modelToWorld [0, 0, 20], [], 0, "NONE"];
_parachute setDir _direction;
_playerVehicle attachTo [_parachute, [0, 0, 0]];

while { _altitude > 5 } do {
    uiSleep 0.01;
    _parachute setVectorUp [0, 0, 1];

    private _forward = if (_isControlling) then {
        inputAction "MoveForward" + inputAction "CarFastForward" - inputAction "MoveBack";
    } else {
        0;
    };
    private _side = if (_isControlling) then {
        inputAction "TurnRight" - inputAction "TurnLeft";
    } else {
        0;
    };
    _parachute setVelocityModelSpace [_side * _paradropMoveSpeed, _forward * _paradropMoveSpeed, -25];

    _altitude = (getPosVisual _playerVehicle) # 2;
};

detach _playerVehicle;
deleteVehicle _parachute;

_playerVehicle setVelocity [0, 0, 0];

if (_isControlling) then {
    ["Paradrop"] spawn WL2_fnc_showHint;
};