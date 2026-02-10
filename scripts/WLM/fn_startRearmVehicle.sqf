#include "includes.inc"
params ["_showWarning"];

private _asset = uiNamespace getVariable "WLM_asset";
private _display = findDisplay WLM_DISPLAY;

private _access = [_asset, player, "full"] call WL2_fnc_accessControl;
if !(_access # 0) exitWith {
    [format ["Cannot rearm: %1", _access # 1]] call WL2_fnc_smoothText;
    playSoundUI ["AddItemFailed"];
    _display closeDisplay 1;
};

private _cooldown = ((_asset getVariable "BIS_WL_nextRearm") - serverTime) max 0;
if (_cooldown > 0) exitWith {
    ["Rearm on cooldown."] call WL2_fnc_smoothText;
    playSoundUI ["AddItemFailed"];
};

private _nearbyVehicles = (_asset nearEntities WL_MAINTENANCE_RADIUS) select { alive _x };
if (count _nearbyVehicles == 0) exitWith {
    ["No rearm sources nearby."] call WL2_fnc_smoothText;
    playSoundUI ["AddItemFailed"];
};

_nearbyVehicles = [_nearbyVehicles, [], { _x getVariable ["WLM_ammoCargo", 0] }, "DESCEND"] call BIS_fnc_sortBy;
private _rearmSource = _nearbyVehicles # 0;
private _amount = _rearmSource getVariable ["WLM_ammoCargo", 0];
if (_amount <= 0) exitWith {
    ["No ammo remaining."] call WL2_fnc_smoothText;
    playSoundUI ["AddItemFailed"];
};

if (player distance _asset > WL_MAINTENANCE_RADIUS) exitWith {
    ["You are too far away from the vehicle to rearm it."] call WL2_fnc_smoothText;
    playSound "AddItemFailed";
};

private _pylonMismatch = false;

// disabled for now
if (_showWarning && _pylonMismatch) exitWith {
    private _confirmDialog = _display createDisplay "WLM_Modal_Dialog";
    private _confirmButtonControl = _confirmDialog displayCtrl WLM_MODAL_CONFIRM_BUTTON;
    private _cancelButtonControl = _confirmDialog displayCtrl WLM_MODAL_EXIT_BUTTON;
    _cancelButtonControl ctrlAddEventHandler ["ButtonClick", {
        (findDisplay WLM_MODAL) closeDisplay 1;
    }];
    _confirmButtonControl ctrlAddEventHandler ["ButtonClick", {
        (findDisplay WLM_MODAL) closeDisplay 1;
        [false, false] call WLM_fnc_startRearmVehicle;
    }];
};

private _massTally = 250;
private _newAmmo = _amount - _massTally;

if (_newAmmo < 0) exitWith {
    [format [localize "STR_WLM_KG_AMMO_REQUIRED", _massTally]] call WL2_fnc_smoothText;
    playSoundUI ["AddItemFailed"];
};

_rearmSource setVariable ["WLM_ammoCargo", _newAmmo, true];

[_asset] remoteExec ["WLM_fnc_rearmVehicle", _asset];

private _rearmTime = WL_UNIT(_asset, "rearm", 600);
_asset setVariable ["BIS_WL_nextRearm", serverTime + _rearmTime, true];

playSound3D ["A3\Sounds_F\sfx\UI\vehicles\Vehicle_Rearm.wss", _asset, false, getPosASL _asset, 2, 1, 75];
[localize "STR_A3_WL_popup_asset_rearmed"] call WL2_fnc_smoothText;