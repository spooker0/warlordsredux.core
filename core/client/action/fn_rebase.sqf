#include "includes.inc"
params ["_asset", "_targetRTB"];

private _sectorName = _targetRTB getVariable ["WL2_name", "Catapult"];

private _message = format [localize "STR_WL_rebaseConfirm", _sectorName, WL_MONEY_SIGN, WL_COST_JETRTB];
private _result = [localize "STR_WL_returnToBase", _message, localize "STR_WL_rebase", localize "STR_WL_cancel"] call WL2_fnc_prompt;

if (!_result) exitWith {
    playSoundUI ["AddItemFailed"];
};

private _spawnParams = if (_sectorName == "Catapult") then {
    [_targetRTB modelToWorld [0, -20, 0], getDir _targetRTB]
} else {
    [_targetRTB] call WL2_fnc_getAirSectorSpawn;
};

_spawnParams params ["_spawnPos", "_dir"];
if (count _spawnPos == 0) exitWith {
    [localize "STR_WL_rebaseNoSafeAirbasePosition"] call WL2_fnc_smoothText;
    playSoundUI ["AddItemFailed"];
};

player action ["LandGear", _asset];

titleCut ["", "BLACK OUT", 1];

uiSleep 1;

private _startWaitTime = serverTime;
[localize "STR_WL_returningToBase"] call WL2_fnc_smoothText;
while { (serverTime - _startWaitTime) < 5 } do {
    _asset setAirplaneThrottle 0;
    _asset engineOn false;
    _asset setVectorDirAndUp [[0, 1, 0], [0, 0, 1]];
    _asset setVelocity [0, 0, 0];
    uiSleep 0.1;
};

_asset setVehiclePosition [_spawnPos, [], 0, "CAN_COLLIDE"];
_asset setVectorDirAndUp [[0, 1, 0], [0, 0, 1]];
_asset setDir _dir;
_asset setVelocity [0, 0, 0];

[player, "jetRTB"] remoteExec ["WL2_fnc_handleClientRequest", 2];

titleCut ["", "BLACK IN", 1];