#include "includes.inc"
params ["_asset", "_caller", "_actionId", "_arguments"];
private _animation = "Acts_TerminalOpen";
[player, [_animation]] remoteExec ["switchMove", 0];

[[0, -3, 1]] call WL2_fnc_actionLockCamera;

["Animation", ["REPAIR", [
    ["Cancel", "Action"],
    ["", "ActionContext"],
    ["", "navigateMenu"]
]], WL_DURATION_REARMAPS, true] spawn WL2_fnc_showHint;

private _startCheckingUnhold = false;
private _timeToStop = serverTime + WL_DURATION_REARMAPS;
private _actionSuccess = false;
while { true } do {
    if (WL_ISDOWN(player)) then {
        break;
    };

    private _inputAction = inputAction "Action" + inputAction "ActionContext" + inputAction "navigateMenu";
    if (_startCheckingUnhold && _inputAction > 0) then {
        break;
    };
    if (_inputAction == 0) then {
        _startCheckingUnhold = true;
    };

    if (_timeToStop <= serverTime) then {
        _actionSuccess = true;
        break;
    };

    uiSleep 0.001;
};

["Animation"] spawn WL2_fnc_showHint;

if (_actionSuccess) then {
    _asset spawn APS_fnc_rearmAPS;
    playSound3D ["A3\Sounds_F\sfx\UI\vehicles\Vehicle_Rearm.wss", _asset, false, getPosASL _asset, 2, 1, 75];
} else {
    playSoundUI ["AddItemFailed"];
};

cameraOn cameraEffect ["Terminate", "BACK"];
[player, [""]] remoteExec ["switchMove", 0];