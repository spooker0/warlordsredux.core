#include "includes.inc"
params ["_asset"];

private _actionID = _asset addAction [
	"<t color='#00ffcc'>Advanced SAM Configuration</t>",
	DIS_fnc_setupAdvancedSamMenu,
	[],
	100,
	true,
	false,
	"",
	"_target == cameraOn",
	50,
	false
];