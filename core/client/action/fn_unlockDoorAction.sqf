#include "includes.inc"
params ["_target"];

// start demolish
[[0, 10, 5]] call WL2_fnc_actionLockCamera;

private _playerPosition = player modelToWorld [0, 0, 0];
private _soundSource = createSoundSource ["WLDemolitionSound", _playerPosition, [], 0];
[player, ["Acts_TerminalOpen"]] remoteExec ["switchMove", 0];

private _demolishSuccess = false;
private _startCheckingUnhold = false;
private _demolitionStepTime = 10;

["Animation", ["DEMOLITION", [
    ["Cancel", "Action"],
    ["", "ActionContext"],
    ["", "navigateMenu"]
]], _demolitionStepTime, true] spawn WL2_fnc_showHint;
["Demolishing hostile door lock... Tip: explosive charges (equip in Arsenal) can quickly unlock hostile doors."] call WL2_fnc_smoothText;

private _endTime = serverTime + _demolitionStepTime;
while { true } do {
    // interrupts
    if (WL_ISDOWN(player)) then {
        break;
    };
    if (!alive _target) then {
        break;
    };
    if (_target getVariable ["WL2_demolitionHealth", 1] <= 0) then {
        break;
    };

    private _inputAction = inputAction "Action" + inputAction "ActionContext" + inputAction "navigateMenu";
    if (_startCheckingUnhold && _inputAction > 0) then {
        break;
    };
    if (_inputAction == 0) then {
        _startCheckingUnhold = true;
    };

    if (serverTime >= _endTime) then {
        _demolishSuccess = true;
        break;
    };
    uiSleep 0.01;
};

["Animation"] spawn WL2_fnc_showHint;

if (_demolishSuccess) then {
    _target setVariable ["WL2_doorsDamaged", serverTime + 30, true];
    playSoundUI ["a3\sounds_f\sfx\objects\upload_terminal\terminal_lock_close.wss"];
} else {
    private _settingsMap = missionProfileNamespace getVariable ["WL2_settings", createHashMap];
    private _hitmarkerVolume = _settingsMap getOrDefault ["hitmarkerVolume", 0.5];
    playSoundUI ["AddItemFailed", _hitmarkerVolume * 2];
};

deleteVehicle _soundSource;
[player, [""]] remoteExec ["switchMove", 0];

cameraOn cameraEffect ["Terminate", "BACK"];