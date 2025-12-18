#include "includes.inc"
addMissionEventHandler ["HandleDisconnect", {
	params ["_unit", "_id", "_uid", "_name"];
	[_uid, false] spawn WL2_fnc_onDisconnect;
	call WL2_fnc_calcImbalance;
}];

addMissionEventHandler ["EntityDeleted", {
	params ["_entity"];
	// do not ever make this a spawn, async calls will break type info
	[_entity, objNull, objNull] call WL2_fnc_handleEntityRemoval;
}];

addMissionEventHandler ["EntityKilled", {
	params ["_unit", "_killer", "_instigator"];
	[_unit, _killer, _instigator] call WL2_fnc_handleEntityRemoval;
}];