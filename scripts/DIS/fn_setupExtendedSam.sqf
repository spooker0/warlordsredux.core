params ["_asset"];

private _actionID = (crew _asset # 0) addAction [
	"<t color='#00ffcc'>Extended SAM Configuration</t>",
	DIS_fnc_setupExtendedSamMenu,
	[],
	100,
	true,
	false,
	"",
	"true",
	50,
	false
];