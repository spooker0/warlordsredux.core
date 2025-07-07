#include "includes.inc"
private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];
private _hideBuyMenu = _settingsMap getOrDefault ["hideBuyMenu", false];
if (!_hideBuyMenu) then {
	player addAction [
		"<t color='#FFFF00'>Buy Menu</t>",
		{
			"RequestMenu_open" call WL2_fnc_setupUI;
		},
		[],
		-200,
		false,
		false,
		"",
		"_this == _target",
		30,
		false
	];
};

private _hideHelpMenu = _settingsMap getOrDefault ["hideHelpMenu", false];
if (!_hideHelpMenu) then {
	player addAction [
		"<t color='#FFFF00'>Help</t>",
		{
			0 spawn WL2_fnc_welcome;
		},
		[],
		-201,
		false,
		false,
		"",
		"_this == _target",
		30,
		false
	];
};
