#include "includes.inc"
params ["_paradropper", "_playerVehicle"];

private _destination = _paradropper modelToWorldWorld [random 200 - 100, random 200 - 100, -30];
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

if (_destination # 2 < 200) then {
    _destination set [2, 200];
};

_playerVehicle setDir (getDir _paradropper);
_playerVehicle setPosASL _destination;
[player, "ftSupportPoints", _paradropper, 1000] remoteExec ["WL2_fnc_handleClientRequest", 2];

waitUntil {
    uiSleep 0.01;
    _playerVehicle setVectorUp [0, 0, 1];
    _playerVehicle setVelocity [0, 0, -400];
    private _alt = (getPosVisual _playerVehicle) # 2;
    _alt < 150;
};

private _parachute = createVehicle [_parachuteClass, _playerVehicle modelToWorld [0, 0, 20], [], 0, "NONE"];
_parachute setDir (getDir _paradropper);
_playerVehicle attachTo [_parachute, [0, 0, 0]];

waitUntil {
    uiSleep 0.01;
    _parachute setVectorUp [0, 0, 1];
    _parachute setVelocity [0, 0, -20];
    private _alt = (getPosVisual _playerVehicle) # 2;
    _alt < 5;
};
detach _playerVehicle;
deleteVehicle _parachute;

uiSleep 0.5;
_playerVehicle setVehiclePosition [getPosATL _playerVehicle, [], 0, "NONE"];