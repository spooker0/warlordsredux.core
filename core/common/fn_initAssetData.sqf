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

private _menuButtonIconMap = createHashMapFromArray [
    ["add-waypoint", "A3\ui_f\data\map\markers\military\box_CA.paa"],
    ["control-driver", "a3\ui_f\data\IGUI\Cfg\CommandBar\imageDriver_ca.paa"],
    ["control-gunner", "a3\ui_f\data\IGUI\Cfg\CommandBar\imageGunner_ca.paa"],
    ["cycle-waypoint", "A3\ui_f\data\map\markers\military\box_CA.paa"],
    ["ew", "a3\ui_f\data\igui\cfg\simpletasks\types\Radio_ca.paa"],
    ["fortify-stronghold", "A3\ui_f\data\map\mapcontrol\Ruin_CA.paa"],
    ["ft-ai", "A3\ui_f\data\map\markers\handdrawn\end_CA.paa"],
    ["ft-asset", "A3\ui_f\data\map\markers\handdrawn\end_CA.paa"],
    ["ft-conflict", "A3\ui_f\data\map\markers\handdrawn\end_CA.paa"],
    ["ft-fob", "A3\ui_f\data\map\markers\handdrawn\end_CA.paa"],
    ["ft-fob-test", "A3\ui_f\data\map\markers\handdrawn\end_CA.paa"],
    ["ft-home", "A3\ui_f\data\map\markers\handdrawn\end_CA.paa"],
    ["ft-parachute", "a3\ui_f\data\map\vehicleicons\iconparachute_ca.paa"],
    ["ft-regular", "A3\ui_f\data\map\markers\handdrawn\end_CA.paa"],
    ["ft-squad", "A3\ui_f\data\map\markers\handdrawn\end_CA.paa"],
    ["ft-squad-leader", "A3\ui_f\data\map\markers\handdrawn\end_CA.paa"],
    ["ft-stronghold", "A3\ui_f\data\map\markers\handdrawn\end_CA.paa"],
    ["ft-stronghold-near", "A3\ui_f\data\map\markers\handdrawn\end_CA.paa"],
    ["ft-stronghold-test", "A3\ui_f\data\map\markers\handdrawn\end_CA.paa"],
    ["ft-tent", "A3\ui_f\data\map\markers\handdrawn\end_CA.paa"],
	["lock-access-control", "a3\modules_f\data\iconunlock_ca.paa"],
	["lock-fob", "a3\modules_f\data\iconunlock_ca.paa"],
    ["loiter", "A3\ui_f\data\map\markers\military\box_CA.paa"],
    ["kick", "a3\modules_f\data\iconunlock_ca.paa"],
    ["mark-sector", "A3\ui_f\data\map\markers\handdrawn\flag_CA.paa"],
    ["move", "A3\ui_f\data\map\markers\military\box_CA.paa"],
    ["order-cap", "a3\ui_f\data\igui\cfg\simpletasks\types\Plane_ca.paa"],
    ["radar-operate", "a3\ui_f\data\igui\cfg\simpletasks\types\Radio_ca.paa"],
    ["radar-rotate", "a3\ui_f\data\igui\cfg\simpletasks\types\Radio_ca.paa"],
    ["remove", "a3\ui_f\data\IGUI\Cfg\Actions\Obsolete\ui_action_cancel_ca.paa"],
    ["remove-fob", "a3\ui_f\data\IGUI\Cfg\Actions\Obsolete\ui_action_cancel_ca.paa"],
    ["remove-stronghold", "a3\ui_f\data\IGUI\Cfg\Actions\Obsolete\ui_action_cancel_ca.paa"],
    ["repair-fob", "a3\ui_f\data\igui\cfg\actions\repair_ca.paa"],
    ["repair-stronghold", "a3\ui_f\data\igui\cfg\actions\repair_ca.paa"],
    ["sector-scan", "a3\drones_f\air_f_gamma\uav_02\data\ui\map_uav_02_ca.paa"],
    ["smart-mine-adjust", "a3\ui_f\data\map\vehicleicons\iconexplosiveuw_ca.paa"],
    ["target-altitude", "a3\ui_f\data\igui\cfg\simpletasks\types\Heli_ca.paa"],
    ["target-loiter-radius", "A3\ui_f\data\map\markers\military\circle_CA.paa"],
	["team-designate", "a3\ui_f\data\igui\cfg\simpletasks\types\move_ca.paa"],
	["upgrade-fob", "A3\ui_f\data\map\markers\military\flag_CA.paa"],
    ["vehicle-paradrop", "a3\ui_f\data\map\vehicleicons\iconparachute_ca.paa"]
];
uiNamespace setVariable ["WL2_mapMenuButtonIcons", _menuButtonIconMap];