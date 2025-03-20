#include "..\..\warlords_constants.inc"
params ["_asset"];

if (isDedicated) exitWith {};

_asset addAction [
    "<t color='#ff0000'>Control Station</t>",
    {
        params ["_asset", "_caller", "_actionId", "_arguments"];
        private _linkedAsset = player getVariable ["WL2_linkedAsset", objNull];

        if (isNull _linkedAsset) exitWith {
            systemChat "You are not linked to an asset!";
            playSound "AddItemFailed";
        };

        private _assetLinkedToPlayer = (_linkedAsset getVariable ["WL2_linkedPlayer", objNull]) == player;
        if (!_assetLinkedToPlayer) exitWith {
            systemChat "You are not linked to an asset!";
            playSound "AddItemFailed";
        };

        [_linkedAsset] spawn DIS_fnc_remoteMunition;
    },
	[],
	100,
	true,
	false,
	"",
	"([_target, _this, 'full'] call WL2_fnc_accessControl) # 0",
	WL_MAINTENANCE_RADIUS,
	false
];
