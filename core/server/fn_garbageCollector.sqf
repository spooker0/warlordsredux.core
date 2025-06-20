#include "includes.inc"
private _list = serverNamespace getVariable ["WL2_garbageCollector", createHashMap];
private _assetData = WL_ASSET_DATA;

private _shouldGarbageCollect = {
	params ["_asset"];
	if (!alive _asset) exitWith { true };
	if (_asset getEntityInfo 12) exitWith { true };
	if (_asset getEntityInfo 2) exitWith { true };
	if (_asset getEntityInfo 11) exitWith { true };
	if (_list getOrDefault [typeOf _asset, false]) exitWith { true };
	false;
};

while { !BIS_WL_missionEnd } do {
	private _collectables = (allMissionObjects "") select {
		[_x] call _shouldGarbageCollect;
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

	sleep WL_COOLDOWN_GC;
};