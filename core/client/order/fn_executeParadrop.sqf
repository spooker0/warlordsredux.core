#include "includes.inc"
params ["_position", "_direction", "_paradropper", "_playerVehicle"];

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

waitUntil {
    uiSleep 0.01;
    _playerVehicle setVectorUp [0, 0, 1];
    _playerVehicle setVelocity [0, 0, -200];
    private _alt = (getPosVisual _playerVehicle) # 2;
    _alt < 200;
};

private _parachute = createVehicle [_parachuteClass, _playerVehicle modelToWorld [0, 0, 20], [], 0, "NONE"];
_parachute setDir _direction;
_playerVehicle attachTo [_parachute, [0, 0, 0]];

while { (getPosVisual _playerVehicle) # 2 > 5 } do {
    uiSleep 0.01;
    _parachute setVectorUp [0, 0, 1];

    private _forward = inputAction "MoveForward" + inputAction "CarFastForward" - inputAction "MoveBack";
    private _side = inputAction "TurnRight" - inputAction "TurnLeft";
    _parachute setVelocityModelSpace [_side * 15, _forward * 15, -25];
};

detach _playerVehicle;
deleteVehicle _parachute;

_playerVehicle setVelocity [0, 0, 0];