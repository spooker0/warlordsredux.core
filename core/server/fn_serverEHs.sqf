#include "includes.inc"
addMissionEventHandler ["HandleDisconnect", {
	params ["_unit", "_id", "_uid", "_name"];
	[_uid] spawn {
		params ["_uid"];

		uiSleep 120;

		private _playerUnit = _uid call BIS_fnc_getUnitByUid;
		if (!isNull _playerUnit) exitWith {};

		private _ownedVehiclesVar = format ["BIS_WL_ownedVehicles_%1", _uid];
		private _ownedVehicles = missionNamespace getVariable [_ownedVehiclesVar, []];
		_ownedVehicles = _ownedVehicles select { alive _x };

		{
			if (unitIsUAV _x) then {
				private _group = group effectiveCommander _x;
				{
					_x deleteVehicleCrew _x;
				} forEach crew _x;
				deleteGroup _group;
			};

			deleteVehicle _x;
		} forEach _ownedVehicles;
		missionNamespace setVariable [_ownedVehiclesVar, []];
	};

	private _minesDB = format ["BIS_WL2_minesDB_%1", _uid];
	{
		_mineData = (missionNamespace getVariable _minesDB) getOrDefault [_x, [0, []]];
		_mines = (_mineData select 1);
		{
			if (!(isNull _x)) then {deleteVehicle _x};
		} forEach _mines;
	} forEach (missionNamespace getVariable _minesDB);
	missionNamespace setVariable [_minesDB, nil];

	{
		if !(isPlayer _x) then {deleteVehicle _x;};
	} forEach ((allUnits) select {(_x getVariable ["BIS_WL_ownerAsset", "132"] == _uid)});

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