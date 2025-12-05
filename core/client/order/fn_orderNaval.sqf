#include "includes.inc"
params ["_class", "_cost"];

"Dropzone" call WL2_fnc_announcer;
[localize "STR_A3_WL_popup_airdrop_selection_water"] call WL2_fnc_smoothText;
if !(visibleMap) then {
	processDiaryLink createDiaryLink ["Map", player, ""];
	WL_CONTROL_MAP ctrlMapAnimAdd [0, 0.1, player];
	ctrlMapAnimCommit WL_CONTROL_MAP;
};

uiNamespace setVariable ["WL2_waterDropCost", _cost];
uiNamespace setVariable ["WL2_waterDropPos", []];

private _selectionBefore = BIS_WL_currentSelection;
BIS_WL_currentSelection = WL_ID_SELECTION_ORDERING_NAVAL;
WL_MapBusy pushBack "orderNaval";

private _mapClickEH = addMissionEventHandler ["MapSingleClick", {
	params ["_units", "_pos", "_alt", "_shift"];
	private _cost = uiNamespace getVariable ["WL2_waterDropCost", -1];

	private _checkBoat = {
		params ["_cost", "_pos"];
		if (!surfaceIsWater _pos) exitWith {
			["Boat must be placed on water surface."] call WL2_fnc_smoothText;
			false;
		};
		if (player distance2D _pos > 300) exitWith {
			["Boat must be placed within 300 meters from your current position."] call WL2_fnc_smoothText;
			false;
		};
		if (_cost < 1000) exitWith {
			true;
		};

		private _forwardBases = missionNamespace getVariable ["WL2_forwardBases", []];
		private _spawnLocations = _forwardBases select {
			_x getVariable ["WL2_forwardBaseOwner", sideUnknown] == BIS_WL_playerSide
		};
		_spawnLocations append (BIS_WL_sectorsArray # 0);

		private _sectorsInRange = _spawnLocations select {
			_pos distance2D _x < 1500;
		};
		private _invalidPlacement = count _sectorsInRange == 0;
		if (_invalidPlacement) then {
			["Boat must be placed within 1.5 km of an owned sector or forward base."] call WL2_fnc_smoothText;
		};
		!_invalidPlacement;
	};

	private _validPlacement = [_cost, _pos] call _checkBoat;

	if (_validPlacement) then {
		uiNamespace setVariable ["WL2_waterDropPos", _pos];
	} else {
		playSound "AddItemFailed";
	};
}];

waitUntil {
	uiSleep WL_TIMEOUT_MIN;
	private _waterDropPos = uiNamespace getVariable ["WL2_waterDropPos", []];
	count _waterDropPos > 0 || !visibleMap;
};

if (BIS_WL_currentSelection == WL_ID_SELECTION_ORDERING_NAVAL) then {
	BIS_WL_currentSelection = _selectionBefore;
};

removeMissionEventHandler ["MapSingleClick", _mapClickEH];

private _waterDropPos = uiNamespace getVariable ["WL2_waterDropPos", []];
if (count _waterDropPos == 0) exitWith {
	"Canceled" call WL2_fnc_announcer;
	[localize "STR_A3_WL_airdrop_canceled"] call WL2_fnc_smoothText;

	uiSleep 1;
	WL_MapBusy = WL_MapBusy - ["orderNaval"];
};

playSound3D ["A3\Data_F_Warlords\sfx\flyby.wss", objNull, false, [_waterDropPos # 0, _waterDropPos # 1, 100]];

_waterDropPos set [2, 0];
"Airdrop" call WL2_fnc_announcer;
[localize "STR_A3_WL_airdrop_underway"] call WL2_fnc_smoothText;
playSound "AddItemOK";

[player, "orderAsset", "naval", _waterDropPos, _class, false] remoteExec ["WL2_fnc_handleClientRequest", 2];

uiSleep 1;
WL_MapBusy = WL_MapBusy - ["orderNaval"];