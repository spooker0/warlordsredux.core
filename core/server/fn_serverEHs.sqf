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

addMissionEventHandler ["MarkerCreated", {
	params ["_marker", "_channelNumber", "_owner", "_local"];

	_list = getArray (missionConfigFile >> "adminFilter");
	_return = ((_list findIf {[_x, (markerText _marker)] call BIS_fnc_inString}) != -1);
	if (((isPlayer _owner) && {(_channelNumber == 0)}) || {_return}) then {
		deleteMarker _marker;
	};
}];