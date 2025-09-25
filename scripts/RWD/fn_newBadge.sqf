#include "includes.inc"
params ["_badgeName"];

private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];
private _useNewKillfeed = _settingsMap getOrDefault ["useNewKillfeed", true];

private _badgeConfigs = createHashMapFromArray [
    ["Grounded", ["A3\\Static_F_Sams\\SAM_System_03\\Data\\UI\\SAM_System_03_icon_CA.paa", 1]],
    ["Air Warfare", ["A3\\Air_F_Jets\\Plane_Fighter_01\\Data\\UI\\Fighter01_icon_ca.paa", 1]],
    ["Tank Superiority", ["A3\\Armor_F_Gamma\\MBT_01\\Data\\ui\\map_slammer_mk4_ca.paa", 1]],
    ["Combat Proficiency", ["A3\\ui_f\\data\\igui\\cfg\\simpletasks\\types\\rifle_ca.paa", 1]],
    ["Vehicle Tactical", ["A3\\soft_f\\MRAP_01\\Data\\UI\\map_MRAP_01_hmg_F_CA.paa", 1]],
	["Naval Combat", ["A3\\boat_f\\Boat_Armed_01\\Data\\UI\\map_boat_armed_01_minigun.paa", 1]],
	["Drone Operator", ["A3\\Air_F_Jets\\UAV_05\\Data\\UI\\uav_05_icon_ca.paa", 1]],
    ["Chopper Proficiency", ["A3\\Air_F_Beta\\Heli_Attack_01\\Data\\UI\\Map_Heli_Attack_01_CA.paa", 1]],
    ["Turret Excellence", ["A3\\Static_F_Gamma\\Data\\UI\\map_StaticTurret_AT_CA.paa", 1]],

	["Air Defense Suppression", ["A3\\Static_F_Sams\\SAM_System_03\\Data\\UI\\SAM_System_03_icon_CA.paa", 2]],
	["Air Superiority", ["A3\\Air_F_Jets\\Plane_Fighter_01\\Data\\UI\\Fighter01_icon_ca.paa", 2]],
	["Tank Destroyer", ["A3\\Armor_F_Gamma\\MBT_01\\Data\\ui\\map_slammer_mk4_ca.paa", 2]],
	["Vehicle Hunter", ["A3\\soft_f\\MRAP_01\\Data\\UI\\map_MRAP_01_hmg_F_CA.paa", 2]],
	["Coast Guard", ["A3\\boat_f\\Boat_Armed_01\\Data\\UI\\map_boat_armed_01_minigun.paa", 2]],
	["Zap", ["A3\\Air_F_Jets\\UAV_05\\Data\\UI\\uav_05_icon_ca.paa", 2]],
	["Chopper Down", ["A3\\Air_F_Beta\\Heli_Attack_01\\Data\\UI\\Map_Heli_Attack_01_CA.paa", 2]],
	["Turret Sweeper", ["A3\\Static_F_Gamma\\Data\\UI\\map_StaticTurret_AT_CA.paa", 2]],

	["Frontline Hero", ["a3\\ui_f\\data\\igui\\cfg\\simpletasks\\types\\attack_ca.paa", 1]],
	["Defender", ["a3\\ui_f\\data\\igui\\cfg\\simpletasks\\types\\defend_ca.paa", 1]],
	["Just One More Rocket", ["A3\\ui_f\\data\\map\\markers\\military\\pickup_CA.paa", 1]],
	["Combat Medic", ["a3\\ui_f\\data\\igui\\cfg\\simpletasks\\types\\Heal_ca.paa", 2]],
	["Spotter", ["a3\\ui_f\\data\\igui\\cfg\\simpletasks\\types\\Radio_ca.paa", 2]],

	["Ace Pilot", ["A3\\Air_F_Jets\\Plane_Fighter_01\\Data\\UI\\Fighter01_icon_ca.paa", 3]],
	["Slow and Steady", ["A3\\Air_F_Beta\\Heli_Attack_01\\Data\\UI\\Map_Heli_Attack_01_CA.paa", 3]],
	["Anti-tank Warfare", ["A3\\soft_f\\MRAP_01\\Data\\UI\\map_MRAP_01_hmg_F_CA.paa", 3]],
	["Heavy Metal", ["A3\\Armor_F_Gamma\\MBT_01\\Data\\ui\\map_slammer_mk4_ca.paa", 3]],
	["Littoral Operator", ["A3\\boat_f\\Boat_Armed_01\\Data\\UI\\map_boat_armed_01_minigun.paa", 3]]
];


if (_useNewKillfeed) then {
	private _display = uiNamespace getVariable ["RscWLKillfeedMenu", displayNull];
	if (isNull _display) then {
		"killfeed" cutRsc ["RscWLKillfeedMenu", "PLAIN", -1, true, true];
		_display = uiNamespace getVariable "RscWLKillfeedMenu";
	};
	private _texture = _display displayCtrl 5502;
	private _badgeData = _badgeConfigs getOrDefault [_badgeName, []];

	if (count _badgeData == 0) exitWith {};
	private _badgeUrl = _badgeData select 0;
	private _badgeLevel = _badgeData select 1;

	private _script = format ["addBadge(""%1"", ""%2"", %3);", toUpper _badgeName, _badgeUrl, _badgeLevel];
	_texture ctrlWebBrowserAction ["ExecJS", _script];
};