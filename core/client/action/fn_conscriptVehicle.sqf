#include "includes.inc"
params ["_conscripter", "_paradropper"];

private _side = side group player;
if (side group _conscripter != _side) exitWith {};
if (WL_IsSpectator) exitWith {};

uiSleep 0.1;

private _playerVehicle = vehicle player;
if (WL_ISUP(player) && !(player in _playerVehicle)) exitWith {};
if (_playerVehicle isKindOf "Air") exitWith {};
private _disableParadrop = WL_UNIT(_playerVehicle, "disableParadrop", 0);
if (_disableParadrop > 0) exitWith {};

if (!alive _paradropper) exitWith {};

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
    if !(player in _playerVehicle) then {
        _canDrop = false;
    };
    if (_playerVehicle isKindOf "Air") then {
        _canDrop = false;
    };
    private _disableParadrop = WL_UNIT(_playerVehicle, "disableParadrop", 0);
    if (_disableParadrop > 0) then {
        _canDrop = false;
    };

    if (!_canDrop) exitWith {
        playSoundUI ["AddItemFailed"];
        ["No longer able to paradrop."] call WL2_fnc_smoothText;
    };

    playSoundUI ["AddItemOk"];

    if (_playerVehicle isKindOf "Man") then {
        [_paradropper, true] spawn WL2_fnc_executeFastTravelVehicle;
    } else {
        private _destination = _paradropper modelToWorldWorld [random 200 - 100, random 200 - 100, -30];
        [_destination, getDir _paradropper, _paradropper, _playerVehicle] spawn WL2_fnc_executeParadrop;
    };
};

private _callbackCancel = {};

[
    "conscriptVehicle",
    _callText,
    "\A3\ui_f\data\map\markers\nato\c_plane.paa",
    localize "STR_WL_goButton", localize "STR_WL_refuseButton",
    _callbackConfirm, _callbackCancel, [_paradropper],
    20, false
] spawn WL2_fnc_timedPrompt;