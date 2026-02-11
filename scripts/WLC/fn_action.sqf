#include "includes.inc"
params ["_flag"];

[_flag] call WL2_fnc_restockAction;

#if WLC_DEBUG
	_flag addAction ["<t color = '#ffff00'>(Debug) Reset Score/Level to 0</t>", {
		[0] call WLC_fnc_setScore;
	}, [], 5, true, true];
	_flag addAction ["<t color = '#ffff00'>(Debug) Add Score +1,000</t>", {
		private _score = ["getScore"] call WLC_fnc_getLevelInfo;
		[_score + 1000] call WLC_fnc_setScore;
	}, [], 5, true, false];
	_flag addAction ["<t color = '#ffff00'>(Debug) Add Score +10,000</t>", {
		private _score = ["getScore"] call WLC_fnc_getLevelInfo;
		[_score + 10000] call WLC_fnc_setScore;
	}, [], 5, true, false];
	_flag addAction ["<t color = '#ffff00'>(Debug) Add Score +100,000</t>", {
		private _score = ["getScore"] call WLC_fnc_getLevelInfo;
		[_score + 100000] call WLC_fnc_setScore;
	}, [], 5, true, false];
	_flag addAction ["<t color = '#ffff00'>(Debug) Set Instant Respawn</t>", {
		setPlayerRespawnTime 1;
	}, [], 5];
	_flag addAction ["<t color = '#ffff00'>(Debug) Set Normal Respawn</t>", {
		setPlayerRespawnTime WL_DURATION_RESPAWN;
	}, [], 5];
#endif