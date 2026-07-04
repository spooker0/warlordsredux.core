#include "includes.inc"
addMissionEventHandler ["Map", {
	params ["_mapIsOpened", "_mapIsForced"];
	if (WL_IsReplaying) exitWith {};

	if (!_mapIsOpened) then {
		0 spawn {
			uiSleep 1;
			BIS_WL_highlightedSector = objNull;
			WL_SectorActionTarget = objNull;

			private _mapButtonDisplay = uiNamespace getVariable ["WL2_mapButtonDisplay", displayNull];
			if (!isNull _mapButtonDisplay) then {
				_mapButtonDisplay closeDisplay 1;
			};

			private _allMaps = uiNamespace getVariable ["WL2_allMaps", []];
			{
				[[], _x] call WL2_fnc_handleSectorIcons;
			} forEach _allMaps;
		};
	};
}];