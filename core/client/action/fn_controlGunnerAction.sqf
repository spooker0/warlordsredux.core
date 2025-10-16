#include "includes.inc"
params ["_asset"];

private _actionId = _asset addAction [
	"<t color='#0000ff'>Swap Pilot/Gunner</t>",
	{
        params ["_target", "_caller", "_actionId"];

        private _vehicle = vehicle player;
        if (gunner _vehicle != player) then {
            player action ["MoveToGunner", _vehicle];
        } else {
            player action ["MoveToPilot", _vehicle];
        };
	},
	[],
	30,
	false,
	true,
	"",
	"[_target, _this] call WL2_fnc_controlGunnerEligibility",
    30,
	false
];