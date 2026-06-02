#include "includes.inc"
params ["_commId"];

player setVariable ["WL2_commMenuItem", [_commId, serverTime + 5], true];

private _listeningPlayers = allPlayers select {
    _x distance player < 500
};

[cameraOn] remoteExec ["WL2_fnc_commMenuListen", _listeningPlayers];