#include "includes.inc"
private _asset = cursorTarget;
if (isNull _asset || !(_asset isKindOf "Air")) exitWith {
    ["No aircraft wreck targeted."] call WL2_fnc_smoothText;
    playSoundUI ["AddItemFailed"];
};

private _isSecured = _asset getVariable ["WL2_isSecured", false];
if (_isSecured) exitWith {
    ["This wreck has already been secured."] call WL2_fnc_smoothText;
    playSoundUI ["AddItemFailed"];
};

private _cost = WL_UNIT(_asset, "cost", 0);
private _inFriendlySector = ([-2, []] call WL2_fnc_checkInFriendlySector) # 0;
if (!_inFriendlySector && _cost > 6000) exitWith {
    ["You can secure this wreck by moving it to a friendly sector or forward base with a flatbed or via slingloading."] call WL2_fnc_smoothText;
    playSoundUI ["AddItemFailed"];
};

_asset setVariable ["WL2_isSecured", true];

deleteVehicle _asset;

private _rewardAmount = round (_cost / 300) * 100;

[player, "secureAircraft", _rewardAmount] remoteExec ["WL2_fnc_handleClientRequest", 2];
[objNull, _rewardAmount, "Aircraft secured", "#228b22"] call WL2_fnc_killRewardClient;

playSoundUI ["AddItemOk"];
playSoundUI ["a3\sounds_f\sfx\ui\vehicles\vehicle_repair.wss"];