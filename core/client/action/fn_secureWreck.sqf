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

private _wreckSide = [_asset] call WL2_fnc_getAssetSide;
if (_wreckSide != BIS_WL_playerSide && _cost > 6000) then {
    private _enemyUnits = switch (_wreckSide) do {
        case west: { BIS_WL_westOwnedVehicles };
        case east: { BIS_WL_eastOwnedVehicles };
        case independent: { BIS_WL_guerOwnedVehicles };
        default { [] };
    };
    private _enemyAirUnits = _enemyUnits select { _x isKindOf "Air" } select {
        private _position = _x modelToWorld [0, 0, 0];
        _position # 2 > 50
    };
    [_enemyAirUnits, 20] remoteExec ["WL2_fnc_reportTargets", BIS_WL_playerSide];
    private _enemiesSpotted = [_enemyAirUnits] call WL2_fnc_reconReward;
    if (_enemiesSpotted) then {
        playSoundUI ["a3\sounds_f_decade\assets\props\linkterminal_01_node_1_f\terminal_captured.wss", 1, 0.5, true];
    };
};

_asset setVariable ["WL2_isSecured", true];

deleteVehicle _asset;

private _rewardAmount = round (_cost / 300) * 100;

[player, "secureAircraft", _rewardAmount] remoteExec ["WL2_fnc_handleClientRequest", 2];
[objNull, _rewardAmount, "Aircraft secured", "#228b22"] call WL2_fnc_killRewardClient;

playSoundUI ["AddItemOk"];
playSound3D ["a3\sounds_f\vehicles\armor\bobcat\bobcat_plow_up_01.wss", _asset];