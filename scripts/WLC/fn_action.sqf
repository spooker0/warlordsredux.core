#include "includes.inc"
params ["_flag"];

[_flag] call WL2_fnc_restockAction;
[_flag] call WL2_fnc_frontlineAction;

#if WL_TEST_SERVER
	_flag addAction ["<t color='#ffff00'>" + localize "STR_WL_debugResetScore" + "</t>", {
		[0] call WLC_fnc_setScore;
	}, [], 5, true, true];
	_flag addAction ["<t color='#ffff00'>" + format [localize "STR_WL_debugAddScore", "1,000"] + "</t>", {
		private _score = ["getScore"] call WLC_fnc_getLevelInfo;
		[_score + 1000] call WLC_fnc_setScore;
	}, [], 5, true, false];
	_flag addAction ["<t color='#ffff00'>" + format [localize "STR_WL_debugAddScore", "10,000"] + "</t>", {
		private _score = ["getScore"] call WLC_fnc_getLevelInfo;
		[_score + 10000] call WLC_fnc_setScore;
	}, [], 5, true, false];
	_flag addAction ["<t color='#ffff00'>" + format [localize "STR_WL_debugAddScore", "100,000"] + "</t>", {
		private _score = ["getScore"] call WLC_fnc_getLevelInfo;
		[_score + 100000] call WLC_fnc_setScore;
	}, [], 5, true, false];
	_flag addAction ["<t color='#ffff00'>" + localize "STR_WL_debugInstantRespawn" + "</t>", {
		setPlayerRespawnTime 1;
	}, [], 5];
	_flag addAction ["<t color='#ffff00'>" + localize "STR_WL_debugNormalRespawn" + "</t>", {
		setPlayerRespawnTime WL_DURATION_RESPAWN;
	}, [], 5];
	_flag addAction ["<t color='#ffff00'>" + localize "STR_WL_spawnGreenSquadronNear" + "</t>", {
		params ["_flag"];
		[player, 4000] remoteExec ["WL2_fnc_makeSquadron", 2];
	}, [], 5];

	_flag addAction ["<t color='#ffff00'>" + localize "STR_WL_spawnGreenSquadronFar" + "</t>", {
		params ["_flag"];
		[player, 20000] remoteExec ["WL2_fnc_makeSquadron", 2];
	}, [], 5];
#endif