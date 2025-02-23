#include "..\..\warlords_constants.inc"

if !(BIS_WL_playerSide in BIS_WL_competingSides) exitWith {};

BIS_WL_playerSide spawn {
	_varName = format ["BIS_WL_recentTargetReset_%1", _this];
	_target = objNull;

	while {!BIS_WL_missionEnd} do {
		if !(BIS_WL_playerSide in BIS_WL_competingSides) exitWith {};

		waitUntil {
			sleep WL_TIMEOUT_STANDARD;
			!isNull WL_TARGET_FRIENDLY
		};

		private _target = WL_TARGET_FRIENDLY;
		waitUntil {
			sleep WL_TIMEOUT_STANDARD;
			isNull WL_TARGET_FRIENDLY
		};

		private _timeout = serverTime + 3;
		waitUntil {
			sleep WL_TIMEOUT_SHORT;
			serverTime > _timeout || (_target getVariable "BIS_WL_owner") == BIS_WL_playerSide || (missionNamespace getVariable [_varName, false])
		};

		if (missionNamespace getVariable [_varName, false]) then {
			"Reset" call WL2_fnc_announcer;

			if (player inArea (_target getVariable "objectAreaComplete")) then {
				["seizing", []] spawn WL2_fnc_setOSDEvent;
			};

			private _enemySectorPreviousOwners = WL_TARGET_ENEMY getVariable ["BIS_WL_previousOwners", []];
			if !(BIS_WL_playerSide in _enemySectorPreviousOwners) then {
				"BIS_WL_targetEnemy" setMarkerAlphaLocal 0;
			};

			if !(isServer) then {
				["client", TRUE] call WL2_fnc_updateSectorArrays;
			};
		};
	};
};

BIS_WL_enemySide spawn {
	_varName = format ["BIS_WL_targetResetOrderedBy_%1", _this];
	_target = objNull;

	while {!BIS_WL_missionEnd} do {
		waitUntil {sleep WL_TIMEOUT_STANDARD; !isNull WL_TARGET_ENEMY};

		_target = WL_TARGET_ENEMY;
		waitUntil {sleep WL_TIMEOUT_STANDARD; isNull WL_TARGET_ENEMY};

		_t = serverTime + 3;
		waitUntil {sleep WL_TIMEOUT_SHORT; serverTime > _t || {(_target getVariable "BIS_WL_owner") == BIS_WL_playerSide || {((missionNamespace getVariable [_varName, ""]) != "")}}};

		if ((missionNamespace getVariable [_varName, ""]) != "") then {
			missionNamespace setVariable [_varName, ""];
			[toUpper format [localize "STR_A3_WL_popup_voting_reset_user", _this call WL2_fnc_sideToFaction]] spawn WL2_fnc_SmoothText;
			missionNamespace setVariable [_varName, ""];
		};
	};
};