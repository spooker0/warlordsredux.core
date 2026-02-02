#include "includes.inc"
params ["_asset"];

if (isDedicated) exitWith {};

[_asset] spawn {
    params ["_asset"];
    private _removeTime = -1;
    while { !isNull _asset } do {
        uiSleep 1;

        if (isInRemainsCollector _asset) then {
            removeFromRemainsCollector [_asset];
        };

        if (_removeTime < 0 && !alive _asset) then {
            _removeTime = serverTime + 300;
        };

        if (serverTime > _removeTime && _removeTime > 0) then {
            if (isNull attachedTo _asset) then {
                deleteVehicle _asset;
            } else {
                _removeTime = serverTime + 60;
            };
        };
    };
};

private _assetActualType = _asset getVariable ["WL2_orderedClass", typeOf _asset];
private _rewardAmount = WL_ASSET(_assetActualType, "cost", 0);
_rewardAmount = round (_rewardAmount / 300) * 100;
private _assetDisplayName = [_asset] call WL2_fnc_getAssetTypeName;

private _secureWreckAction = _asset addAction [
	format ["Secure Wreck for %1 (%2%3)", _assetDisplayName, WL_MoneySign, _rewardAmount],
	{
        params ["_asset", "_caller", "_actionId", "_arguments"];
        private _rewardAmount = _arguments select 0;

        private _inFriendlySector = ([-2, []] call WL2_fnc_checkInFriendlySector) # 0;
        if (!_inFriendlySector && _rewardAmount > 1333) exitWith {
            ["You can secure this wreck by moving it to a friendly sector or forward base with a flatbed or via slingloading."] call WL2_fnc_smoothText;
            playSoundUI ["AddItemFailed"];
        };

        [player, "secureAircraft", _rewardAmount] remoteExec ["WL2_fnc_handleClientRequest", 2];
        [objNull, _rewardAmount, "Aircraft secured", "#228b22"] call WL2_fnc_killRewardClient;

        _asset removeAction _actionId;
        deleteVehicle _asset;

        playSoundUI ["AddItemOk"];
        playSoundUI ["a3\sounds_f\sfx\ui\vehicles\vehicle_repair.wss"];
	},
	[_rewardAmount],
	10,
	false,
	true,
	"",
	"!alive _target",
    30,
	false
];