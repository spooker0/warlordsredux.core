#include "includes.inc"
private _hideBuyMenu = _settingsMap getOrDefault ["hideBuyMenu", false];
if (_hideBuyMenu) exitWith {};

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