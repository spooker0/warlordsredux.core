#include "includes.inc"

while { !BIS_WL_missionEnd } do {
	private _prevSectorFriendly = missionNamespace getVariable ["WL2_prevSectorFriendly", objNull];
	private _prevSectorEnemy = missionNamespace getVariable ["WL2_prevSectorEnemy", objNull];

	if (_prevSectorFriendly != WL_TARGET_FRIENDLY) then {
		if !(isNull _prevSectorFriendly) then {
			[_prevSectorFriendly, BIS_WL_playerSide, false] call WL2_fnc_targetSelected;
		};
		if !(isNull WL_TARGET_FRIENDLY) then {
			[WL_TARGET_FRIENDLY, BIS_WL_playerSide, true] call WL2_fnc_targetSelected;
		};
		missionNamespace setVariable ["WL2_prevSectorFriendly", WL_TARGET_FRIENDLY];
	};
	if (_prevSectorEnemy != WL_TARGET_ENEMY) then {
		if !(isNull _prevSectorEnemy) then {
			[_prevSectorEnemy, BIS_WL_enemySide, false] call WL2_fnc_targetSelected;
		};
		if !(isNull WL_TARGET_ENEMY) then {
			[WL_TARGET_ENEMY, BIS_WL_enemySide, true] call WL2_fnc_targetSelected;
		};
		missionNamespace setVariable ["WL2_prevSectorEnemy", WL_TARGET_ENEMY];
	};

	if (isNull WL_TARGET_FRIENDLY) then {
		uiSleep 0.25;
	} else {
		uiSleep 1;
	};
};