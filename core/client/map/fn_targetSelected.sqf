#include "..\..\warlords_constants.inc"

params ["_sector", "_side", "_selected"];

if (_side != BIS_WL_playerSide) exitWith {
	if (_selected) then {
		"BIS_WL_targetEnemy" setMarkerPosLocal position _sector;

		if ((_sector getVariable "BIS_WL_owner") == BIS_WL_playerSide || {_sector == WL_TARGET_FRIENDLY}) then {
			"Incoming" call WL2_fnc_announcer;
			[toUpper format [localize "STR_A3_WL_incoming", _sector getVariable "WL2_name", BIS_WL_enemySide call WL2_fnc_sideToFaction]] spawn WL2_fnc_smoothText;
		};

		if (_sector == (BIS_WL_playerSide call WL2_fnc_getSideBase)) then {
			playSound "air_raid";
			playSound "air_raid";
			[toUpper localize "STR_A3_WL_popup_base_vulnerable"] spawn WL2_fnc_smoothText;
			if !(isServer) then {
				["base_vulnerable", BIS_WL_playerSide] call WL2_fnc_handleRespawnMarkers;
			};
		};

		_sector spawn {
			params ["_sector"];

			waitUntil {sleep WL_TIMEOUT_STANDARD; BIS_WL_playerSide in (_sector getVariable ["BIS_WL_revealedBy", []]) || {WL_TARGET_ENEMY != _sector}};

			if (WL_TARGET_ENEMY == _sector) then {
				"BIS_WL_targetEnemy" setMarkerAlphaLocal 1;
				if (_sector == WL_TARGET_FRIENDLY) then {"BIS_WL_targetEnemy" setMarkerDirLocal 45};
			};
		};
	} else {
		"BIS_WL_targetEnemy" setMarkerAlphaLocal 0;
		"BIS_WL_targetEnemy" setMarkerDirLocal 0;
		if ((markerPos "BIS_WL_targetEnemy") distance2D (BIS_WL_playerSide call WL2_fnc_getSideBase) < 1 && {!isServer}) then {
			["base_safe", BIS_WL_playerSide] call WL2_fnc_handleRespawnMarkers;
		};
	};
};

private _markers = _sector getVariable "BIS_WL_markers";
if (_selected) then {
	(_markers # 1) setMarkerBrushLocal "Border";
	"BIS_WL_targetFriendly" setMarkerPosLocal position _sector;
	"BIS_WL_targetFriendly" setMarkerAlphaLocal 1;

	_sector spawn {
		params ["_sector"];

		waitUntil {sleep WL_TIMEOUT_STANDARD; BIS_WL_playerSide in (_sector getVariable ["BIS_WL_revealedBy", []]) || {WL_TARGET_ENEMY != _sector}};

		if (WL_TARGET_ENEMY == _sector) then {
			if (_sector == WL_TARGET_ENEMY) then {"BIS_WL_targetEnemy" setMarkerDirLocal 45};
		};
	};
} else {
	(_markers # 1) setMarkerBrushLocal "Solid";

	"BIS_WL_targetFriendly" setMarkerAlphaLocal 0;
	"BIS_WL_targetEnemy" setMarkerDirLocal 0;
};