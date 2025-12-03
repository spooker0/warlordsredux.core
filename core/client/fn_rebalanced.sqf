#include "includes.inc"
["You have been rebalanced."] call WL2_fnc_smoothText;
"common" call WL2_fnc_varsInit;
"client" call WL2_fnc_varsInit;
["client", true] call WL2_fnc_updateSectorArrays;
{
	[_x, _x getVariable "BIS_WL_owner"] call WL2_fnc_sectorMarkerUpdate;
} forEach BIS_WL_allSectors;
call WL2_fnc_arsenalSetup;
forceRespawn player;