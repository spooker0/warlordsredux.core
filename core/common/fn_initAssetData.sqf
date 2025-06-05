#include "includes.inc"

if (isServer) then {
	serverNamespace setVariable ["fundsDatabase", createHashMap];
	serverNamespace setVariable ["playerList", createHashMap];

	serverNamespace setVariable ["WL2_garbageCollector",
		createHashMapFromArray [
			["Steerable_Parachute_F", true],
			["Land_Cargo_Tower_V4_ruins_F", true],
			["Land_MobileRadar_01_radar_ruins_F", true],
			["B_Ejection_Seat_Plane_Fighter_01_F", true],
			["O_Ejection_Seat_Plane_Fighter_02_F", true],
			["I_Ejection_Seat_Plane_Fighter_03_F", true],
			["B_Ejection_Seat_Plane_CAS_01_F", true],
			["O_Ejection_Seat_Plane_CAS_02_F", true],
			["Plane_Fighter_03_Canopy_F", true],
			["Plane_CAS_02_Canopy_F", true],
			["Plane_CAS_01_Canopy_F", true],
			["Plane_Fighter_01_Canopy_F", true],
			["Plane_Fighter_02_Canopy_F", true],
			["Plane_Fighter_04_Canopy_F", true] //<--no comma on last item
		]
	];
};

private _requisitionData = createHashMap;

private _requisitionPreset = missionConfigFile >> "CfgWLRequisitionPresets" >> "A3ReduxAll";
{
	private _categories = configProperties [_x];
	{
		private _categoryName = configName _x;
		private _classes = configProperties [_x];

		{
			private _classConfig = _x;
			private _className = configName _classConfig;
			private _classMap = createHashMap;

			_classMap set ["category", _categoryName];

			{
				private _entry = _x;
				private _key = configName _entry;
				if (isText _entry) then {
					_classMap set [_key, getText _entry];
					continue;
				};
				if (isNumber _entry) then {
					_classMap set [_key, getNumber _entry];
					continue;
				};
				if (isArray _entry) then {
					_classMap set [_key, getArray _entry];
					continue;
				};
			} forEach configProperties [_classConfig];

			private _turretOverrides = "inheritsFrom _x == (missionConfigFile >> 'WLTurretDefaults')" configClasses _classConfig;
			_classMap set ["turretOverrides", _turretOverrides];

			_requisitionData set [_className, _classMap];
		} forEach _classes;
	} forEach _categories;
} forEach configProperties [_requisitionPreset];

missionNamespace setVariable ["WL2_assetData", _requisitionData];