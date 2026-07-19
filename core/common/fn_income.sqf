#include "includes.inc"
params ["_side"];

if (_side == independent) exitWith {
	200;
};

if (!isServer) exitWith { 0 };

private _teamSectorsData = WL_SECTORS_DATA(_side);
_teamSectorsData getOrDefault ["income", 0];