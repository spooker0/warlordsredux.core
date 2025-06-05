#include "includes.inc"
private _list = serverNamespace getVariable ["WL2_garbageCollector", createHashMap];
private _assetData = WL_ASSET_DATA;

while {!BIS_WL_missionEnd} do {
	private _collectables = (allMissionObjects "") select {
		!alive _x;
	} select {
		_x getEntityInfo 12; // wreck
	} select {
		_x getEntityInfo 2; // dead set
	} select {
		_x getEntityInfo 11; // weapon holder
	} select {
		_list getOrDefault [typeOf _x, false]; // basic list
	} select {
		private _assetActualType = _x getVariable ["WL2_orderedClass", typeOf _x];
		WL_ASSET_FIELD(_assetData, _assetActualType, "garbageCollect", false);
	};

	{
		if (typeOf _x == "Steerable_Parachute_F") then {
			private _occupied = count (crew _x select {alive _x}) > 0;
			if (!_occupied) then {
				deleteVehicle _x;
			};
		} else {
			deleteVehicle _x;
		};
	} forEach _collectables;

	private _simpleObjects = allSimpleObjects [];
	{
		private _modelInfo = getModelInfo _x;
		private _modelName = _modelInfo # 0;
		if (_modelName == "b_ArundoD3s_F.p3d") then {
			private _placedTime = _x getVariable ["WL2_placedTime", 0];
			if ((serverTime - _placedTime) > 300) then {
				deleteVehicle _x;
			};
		};
	} forEach _simpleObjects;

	sleep 60;
};