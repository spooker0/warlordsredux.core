#include "includes.inc"
if (isDedicated) exitWith {};

private _actionId = player addAction [
	"<t color='#00FF00'>Secure Wreck</t>",
	{
        0 spawn WL2_fnc_secureWreck;
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

        private _cost = WL_UNIT(_asset, "cost", 0);
        private _rewardAmount = round (_cost / 300) * 100;
        private _targetDisplayName = [_asset] call WL2_fnc_getAssetTypeName;

        player setUserActionText [_actionId, format ["<t color='#00FF00'>Secure Wreck for %1 (%2%3)</t>", _targetDisplayName, WL_MONEY_SIGN, _rewardAmount]];
	};
};