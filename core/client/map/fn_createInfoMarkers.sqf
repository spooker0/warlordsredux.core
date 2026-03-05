#include "includes.inc"
private _menuKey = actionKeysNames ["gear", 1, "Combo"];
private _pingKey = actionKeysNames ["TacticalPing", 1, "Combo"];
private _pttKey = actionKeysNames ["pushToTalk", 1, "Combo"];
private _chatKey = actionKeysNames ["chat", 1, "Combo"];
private _revealKey = actionKeysNames ["revealTarget", 1, "Combo"];
private _infoMarkers = [
	[localize "STR_WL_mapInfoText1", "mil_box_noShadow", "ColorRed"],
	[localize "STR_WL_mapInfoText2", "mil_box_noShadow", "ColorRed"],
	["https://discord.gg/grmzsZE4ua", "mil_box_noShadow", "ColorRed"],
	[],
	["   " + localize "STR_WL_mapInfoText3", "loc_talk", "ColorGreen"],
	[format [localize "STR_WL_mapInfoText4", _menuKey], "mil_box_noShadow", "ColorYellow"],
	[format [localize "STR_WL_mapInfoText5", _menuKey], "mil_box_noShadow", "ColorYellow"],
	[format [localize "STR_WL_mapInfoText6", _pingKey], "mil_box_noShadow", "ColorYellow"],
	[format [localize "STR_WL_mapInfoText7", _pttKey, _chatKey], "mil_box_noShadow", "ColorYellow"],
	[],
	["   " + localize "STR_WL_mapInfoText8", "loc_talk", "ColorGreen"],
	[localize "STR_WL_mapInfoText9", "mil_box_noShadow", "ColorYellow"],
	[localize "STR_WL_mapInfoText10", "mil_box_noShadow", "ColorYellow"],
	[format [localize "STR_WL_mapInfoText11", _revealKey], "mil_box_noShadow", "ColorYellow"]
];
{
	if (count _x == 0) then {
		continue;
	};

	private _marker = createMarkerLocal [
		format ["WL2_infoMarker_%1", _forEachIndex],
		[31000, 30600 - _forEachIndex * 300, 0]
	];
	_marker setMarkerTextLocal (_x # 0);
	_marker setMarkerTypeLocal (_x # 1);
	_marker setMarkerColorLocal (_x # 2);
} forEach _infoMarkers;