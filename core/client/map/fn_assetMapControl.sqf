#include "includes.inc"
addMissionEventHandler ["EachFrame", WL2_fnc_mapEachFrame];

addMissionEventHandler ["Map", {
	params ["_mapIsOpened", "_mapIsForced"];
	if (WL_IsReplaying) exitWith {};

	private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];
	private _userMarkerAlpha = if (_settingsMap getOrDefault ["showMarkers", true]) then {
		1;
	} else {
		0;
	};
	{
		if ("_USER_DEFINED #" in _x) then {
			_x setMarkerAlphaLocal _userMarkerAlpha;
		};
	} forEach allMapMarkers;

	if (!_mapIsOpened) then {
		BIS_WL_highlightedSector = objNull;
		BIS_WL_hoverSamplePlayed = false;
		WL_SectorActionTarget = objNull;

		private _mapButtonDisplay = uiNamespace getVariable ["WL2_mapButtonDisplay", displayNull];
		if (!isNull _mapButtonDisplay) then {
			_mapButtonDisplay closeDisplay 1;
		};
	};
}];