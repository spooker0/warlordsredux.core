#include "..\server_macros.inc"

while { !BIS_WL_missionEnd } do {
	sleep 60;

	private _notBlocked = allPlayers select {
		!(_x getVariable ["WL2_afk", false])
	};

	{
		private _calculatedIncome = if (side group _x == independent) then {
			200;
		} else {
			serverNamespace getVariable [variable, 40];
		};

		[_calculatedIncome max 50, getPlayerUID _x] call WL2_fnc_fundsDatabaseWrite;
	} forEach _notBlocked;

	private _forwardBases = missionNamespace getVariable ["WL2_forwardBases", []];
	_forwardBases = _forwardBases select {
		alive _x &&
		_x getVariable ["WL2_forwardBaseTime", 0] < serverTime
	};

    {
		private _supplies = _x getVariable ["WL2_forwardBaseSupplies", 0];
		_x setVariable ["WL2_forwardBaseSupplies", _supplies + 1000, true];
    } forEach _forwardBases;
};