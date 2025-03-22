params ["_asset"];

private _actionText = format ["<t color='#00ffcc'>Remote Munition Configuration (%1)</t>", actionKeysNames ["binocular", 1, "Combo"]];
private _actionID = _asset addAction [
	_actionText,
	DIS_fnc_setupRemoteMenu,
	[],
	100,
	true,
	false,
	"binocular",
	"vehicle _this == _target",
	50,
	false
];
