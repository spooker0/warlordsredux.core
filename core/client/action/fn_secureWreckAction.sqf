#include "includes.inc"
if (isDedicated) exitWith {};

private _actionId = player addAction [
	"<t color='#00FF00'>Secure Wreck</t>",
	{
        params ["_target", "_caller", "_actionId", "_args"];
        private _asset = cursorTarget;
        if (isNull _asset || !(_asset isKindOf "Air")) exitWith {
            ["No aircraft wreck targeted."] call WL2_fnc_smoothText;
            playSoundUI ["AddItemFailed"];
        };

        private _assetActualType = _asset getVariable ["WL2_orderedClass", typeOf _asset];
        private _rewardAmount = WL_ASSET(_assetActualType, "cost", 0);
        _rewardAmount = round (_rewardAmount / 300) * 100;

        private _inFriendlySector = ([-2, []] call WL2_fnc_checkInFriendlySector) # 0;
        if (!_inFriendlySector && _rewardAmount > 1333) exitWith {
            ["You can secure this wreck by moving it to a friendly sector or forward base with a flatbed or via slingloading."] call WL2_fnc_smoothText;
            playSoundUI ["AddItemFailed"];
        };

        [player, "secureAircraft", _rewardAmount] remoteExec ["WL2_fnc_handleClientRequest", 2];
        [objNull, _rewardAmount, "Aircraft secured", "#228b22"] call WL2_fnc_killRewardClient;

        deleteVehicle _asset;

        playSoundUI ["AddItemOk"];
        playSoundUI ["a3\sounds_f\sfx\ui\vehicles\vehicle_repair.wss"];
	},
	[],
	100,
	false,
	true,
	"",
	"!alive cursorTarget && cursorTarget isKindOf 'Air' && cameraOn distance cursorTarget < 50",
	30,
	false
];

[_actionId] spawn {
	params ["_actionId"];
    private _originalText = "<t color='#00FF00'>Secure Wreck</t>";
	while { alive player } do {
        uiSleep 0.1;

        private _asset = cursorTarget;
        if (alive _asset) then {
            player setUserActionText [_actionId, _originalText];
            continue;
        };
        if !(_asset isKindOf "Air") then {
            player setUserActionText [_actionId, _originalText];
            continue;
        };

        private _assetActualType = _asset getVariable ["WL2_orderedClass", typeOf _asset];
        private _rewardAmount = WL_ASSET(_assetActualType, "cost", 0);
        _rewardAmount = round (_rewardAmount / 300) * 100;
        private _targetDisplayName = [_asset] call WL2_fnc_getAssetTypeName;

        player setUserActionText [_actionId, format ["<t color='#00FF00'>Secure Wreck for %1 (%2%3)</t>", _targetDisplayName, WL_MoneySign, _rewardAmount]];
	};
};