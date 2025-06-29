#include "includes.inc"
params ["_asset"];

_asset addAction [
	format ["<t color='#00ffcc'>SEAD Configuration (%1)</t>", actionKeysNames ["throw", 1, "Combo"]],
	{
		params ["_target", "_caller"];
		[_target, DIS_fnc_getSeadTarget] call DIS_fnc_setupTargetMenu;
	},
	[],
	100,
	true,
	false,
	"throw",
	"[_target, _this] call DIS_fnc_setupSeadActionEligibility",
	50,
	false
];