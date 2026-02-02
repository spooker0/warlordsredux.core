#include "includes.inc"
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

private _flag = if (BIS_WL_playerSide == west) then {
	"flag_NATO"
} else {
	"flag_CSAT"
};
private _enemyFlag = if (BIS_WL_playerSide == west) then {
	"flag_CSAT"
} else {
	"flag_NATO"
};

private _friendlyAreaMarker = createMarkerLocal ["WL2_infoMarker_areaFriendly", [15000, 15000, 0]];
_friendlyAreaMarker setMarkerTypeLocal _flag;
_friendlyAreaMarker setMarkerColorLocal "ColorWhite";

private _enemyAreaMarker = createMarkerLocal ["WL2_infoMarker_areaEnemy", [15000, 14000, 0]];
_enemyAreaMarker setMarkerTypeLocal _enemyFlag;
_enemyAreaMarker setMarkerColorLocal "ColorWhite";

while { !BIS_WL_missionEnd } do {
	private _side = if (BIS_WL_playerSide == west) then { "west" } else { "east" };
	private _areaVar = format ["WL2_%1ControlledArea", _side];
	private _controlledArea = missionNamespace getVariable [_areaVar, 0];
	_friendlyAreaMarker setMarkerTextLocal format ["    Friendly: %1 km²", (_controlledArea / 1000000) toFixed 1];

	private _enemySide = if (BIS_WL_playerSide == west) then { "east" } else { "west" };
	private _enemyAreaVar = format ["WL2_%1ControlledArea", _enemySide];
	private _enemyControlledArea = missionNamespace getVariable [_enemyAreaVar, 0];

	private _areaText = switch (true) do {
		case (_controlledArea < 5000000): { "<5" };
		case (_controlledArea < 10000000): { "5-10" };
		case (_controlledArea < 15000000): { "10-15" };
		case (_controlledArea < 20000000): { "15-20" };
		case (_controlledArea < 25000000): { "20-25" };
		case (_controlledArea < 30000000): { "25-30" };
		case (_controlledArea < 35000000): { "30-35" };
		case (_controlledArea < 40000000): { "35-40" };
		case (_controlledArea < 45000000): { "40-45" };
		case (_controlledArea < 50000000): { "45-50" };
		case (_controlledArea >= 50000000): { ">50" };
		default { "<5" };
	};
	_enemyAreaMarker setMarkerTextLocal format ["    Enemy: %1 km²", _areaText];

	uiSleep 30;
};