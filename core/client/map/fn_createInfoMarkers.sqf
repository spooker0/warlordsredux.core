private _menuKey = actionKeysNames ["gear", 1, "Combo"];
private _pingKey = actionKeysNames ["TacticalPing", 1, "Combo"];
private _pttKey = actionKeysNames ["pushToTalk", 1, "Combo"];
private _chatKey = actionKeysNames ["chat", 1, "Combo"];
private _revealKey = actionKeysNames ["revealTarget", 1, "Combo"];
private _infoMarkers = [
	[localize "WL2_InfoText_1", "mil_box_noShadow", "ColorRed"],
	[localize "WL2_InfoText_2", "mil_box_noShadow", "ColorRed"],
	["https://discord.gg/grmzsZE4ua", "mil_box_noShadow", "ColorRed"],
	[],
	["   " + localize "WL2_InfoText_3", "loc_talk", "ColorGreen"],
	[format [localize "WL2_InfoText_4", _menuKey], "mil_box_noShadow", "ColorYellow"],
	[format [localize "WL2_InfoText_5", _menuKey], "mil_box_noShadow", "ColorYellow"],
	[format [localize "WL2_InfoText_6", _pingKey], "mil_box_noShadow", "ColorYellow"],
	[format [localize "WL2_InfoText_7", _pttKey, _chatKey], "mil_box_noShadow", "ColorYellow"],
	[],
	["   " + localize "WL2_InfoText_8", "loc_talk", "ColorGreen"],
	[localize "WL2_InfoText_9", "mil_box_noShadow", "ColorYellow"],
	[localize "WL2_InfoText_10", "mil_box_noShadow", "ColorYellow"],
	[format [localize "WL2_InfoText_11", _revealKey], "mil_box_noShadow", "ColorYellow"]
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