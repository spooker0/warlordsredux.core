#include "includes.inc"
params ["_conscripter", "_paradropper"];

private _side = side group player;
if (side group _conscripter != _side) exitWith {};
if (WL_IsSpectator) exitWith {};

uiSleep 0.1;

private _playerVehicle = vehicle player;
if (WL_ISUP(player) && driver _playerVehicle != player) exitWith {};    // do not ask passengers
if (_playerVehicle isKindOf "Air") exitWith {};

if (!alive _paradropper) exitWith {};
if ((_paradropper modelToWorld [0, 0, 0]) # 2 < 100) exitWith {};

private _callText = format ["%1 is paradropping troops and vehicles. Would you like to paradrop now?", name _conscripter];

private _callbackConfirm = {
    params ["_paradropper"];
    private _queue = uiNamespace getVariable "WL2_timedPromptQueue";
    {
        if (_x # 0 == "conscriptVehicle") then {
            _x set [1, true];
        };
    } forEach _queue;

    if (WL_ISDOWN(player)) then {
        setPlayerRespawnTime 0.1;
        forceRespawn player;

        waitUntil {
            uiSleep 0.1;
            WL_ISUP(player);
        };
    };

    private _playerVehicle = vehicle player;
    private _canDrop = true;
    if (!alive _paradropper) then {
        _canDrop = false;
    };
    if ((_paradropper modelToWorld [0, 0, 0]) # 2 < 100) then {
        _canDrop = false;
    };
    if (driver _playerVehicle != player) then {
        _canDrop = false;
    };
    if (_playerVehicle isKindOf "Air") then {
        _canDrop = false;
    };

    if (!_canDrop) exitWith {
        playSoundUI ["AddItemFailed"];
        ["No longer able to paradrop."] call WL2_fnc_smoothText;
    };

    playSoundUI ["AddItemOk"];

    if (_playerVehicle isKindOf "Man") then {
        [_paradropper] spawn WL2_fnc_executeFastTravelVehicle;
    } else {
        private _destination = _paradropper modelToWorldWorld [random 300 - 150, random 300 - 150, -30];
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

        _playerVehicle setPosASL _destination;

        waitUntil {
            uiSleep 0.1;
            private _alt = (getPosVisual _playerVehicle) # 2;
            _alt < 150;
        };

        private _parachute = createVehicle [_parachuteClass, _playerVehicle modelToWorld [0, 0, 20], [], 0, "NONE"];
        _playerVehicle attachTo [_parachute, [0, 0, 0]];

        waitUntil {
            uiSleep 0.01;
            _parachute setVelocity [0, 0, -10];
            _parachute setVectorUp [0, 0, 1];
            private _alt = (getPosVisual _playerVehicle) # 2;
            _alt < 5;
        };
        detach _playerVehicle;
        deleteVehicle _parachute;

        uiSleep 0.5;
        _playerVehicle setVehiclePosition [getPosATL _playerVehicle, [], 0, "NONE"];
    };
};

private _callbackCancel = {};

[
    "conscriptVehicle",
    _callText,
    "\A3\ui_f\data\map\markers\nato\c_plane.paa",
    localize "STR_WL_goButton", localize "STR_WL_refuseButton",
    _callbackConfirm, _callbackCancel, [_paradropper],
    20, _playerVehicle == player
] spawn WL2_fnc_timedPrompt;