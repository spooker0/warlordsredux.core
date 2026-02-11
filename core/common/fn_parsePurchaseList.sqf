#include "includes.inc"
params ["_side"];

private _purchaseable = [_side] call WL2_fnc_parseAssetPurchases;
private _fastTravelArr = [
	[
		"FTPriority",
		0,
		[],
		localize "STR_WL_ftFrontline",
		"\A3\Data_F_Warlords\Data\preview_ft_owned.jpg",
		localize "STR_WL_ftFrontlineInfo"
	], [
		"FTHome",
		0,
		[],
		localize "STR_WL_ftHome",
		"\A3\EditorPreviews_F_Decade\Data\CfgVehicles\PortableFlagPole_01_F.jpg",
		localize "STR_WL_ftHome"
	], [
		"FTSeized",
		0,
		[],
		localize "STR_A3_WL_menu_fasttravel_seized",
		"\A3\Data_F_Warlords\Data\preview_ft_owned.jpg",
		localize "STR_A3_WL_menu_fasttravel_info"
	], [
		"FTAirAssault",
		WL_COST_AIRASSAULT,
		[],
		localize "STR_WL_ftAirAssault",
		"\A3\EditorPreviews_F\Data\CfgVehicles\VR_Area_01_circle_4_grey_F.jpg",
		localize "STR_WL_ftAirAssaultInfo"
	], [
		"FTParadropVehicle",
		WL_COST_PARADROP,
		[],
		localize "STR_WL_ftParadrop",
		"\A3\EditorPreviews_F\Data\CfgVehicles\VR_Area_01_circle_4_grey_F.jpg",
		localize "STR_WL_ftParadropInfo"
	], [
		"FTSquadLeader",
		WL_COST_FTSL,
		[],
		localize "STR_WL_ftSquadLeader",
		"\A3\Data_F_Warlords\Data\preview_ft_conflict.jpg",
		localize "STR_WL_ftSquadLeader"
	], [
		"RespawnBagFT",
		0,
		[],
		localize "STR_WL_ftTent",
		"\A3\EditorPreviews_F\Data\CfgVehicles\Land_TentA_F.jpg",
		localize "STR_WL_ftTentInfo"
	], [
		"StrongholdFT",
		0,
		[],
		localize "STR_WL_ftStronghold",
		"\A3\EditorPreviews_F\Data\CfgVehicles\Land_Cargo_Tower_V3_F.jpg",
		localize "STR_WL_ftStrongholdInfo"
	], [
		"BuyFOB",
		WL_COST_SUPPLIES,
		[],
		localize "STR_WL_ftBuySupplies",
		"\A3\EditorPreviews_F_Decade\Data\CfgVehicles\RuggedTerminal_01_communications_hub_F.jpg",
		localize "STR_WL_ftBuySuppliesInfo"
	], [
		"BuyStronghold",
		WL_COST_STRONGHOLD,
		[],
		localize "STR_WL_ftBuyStronghold",
		"\A3\EditorPreviews_F\Data\CfgVehicles\Land_Cargo_Tower_V3_F.jpg",
		localize "STR_WL_ftBuyStrongholdInfo"
	]
];

#if WL_FASTTRAVEL_CONFLICT
_fastTravelArr pushBack [
	"FTConflict",
	WL_COST_FTCONTESTED,
	[],
	localize "STR_A3_WL_menu_fasttravel_conflict",
	"\A3\Data_F_Warlords\Data\preview_ft_conflict.jpg",
	localize "STR_A3_WL_menu_fasttravel_info"
];
#endif

private _ftCategoryIndex = WL_REQUISITION_CATEGORIES find "Fast Travel";
if (_ftCategoryIndex != -1) then {
	_purchaseable set [_ftCategoryIndex, _fastTravelArr];
};

private _strategyArr = [
	[
		"Scan",
		WL_COST_SCAN,
		[],
		localize "STR_A3_WL_param4_title",
		"\A3\Data_F_Warlords\Data\preview_scan.jpg",
		localize "STR_A3_WL_menu_scan_info"
	], [
		"CombatAir",
		WL_COST_COMBATAIR,
		[],
		localize "STR_WL_combatAirPatrol",
		"\a3\ui_f\data\igui\cfg\simpletasks\types\Plane_ca.paa",
		localize "STR_WL_combatAirPatrolInfo"
	], [
		"Conscription",
		WL_COST_CONSCRIPT,
		[],
		localize "STR_WL_conscript",
		"\a3\ui_f\data\igui\cfg\simpletasks\types\rifle_ca.paa",
		localize "STR_WL_conscriptInfo"
	], [
		"FundsTransfer",
		WL_COST_FUNDTRANSFER,
		[],
		localize "STR_WL_transferMoney",
		"\A3\Data_F_Warlords\Data\preview_cp_transfer.jpg",
		localize "STR_A3_WL_menu_fundstransfer_info"
	], [
		"TargetReset",
		WL_COST_TARGETRESET,
		[],
		localize "STR_A3_WL_menu_resetvoting",
		"\A3\Data_F_Warlords\Data\preview_ft_conflict.jpg",
		localize "STR_A3_WL_menu_resetvoting_info"
	], [
		"LockVehicles",
		0,
		[],
		localize "STR_A3_WL_feature_lock_all",
		"\A3\Data_F_Warlords\Data\preview_empty.jpg",
		""
	], [
		"UnlockVehicles",
		0,
		[],
		localize "STR_A3_WL_feature_unlock_all",
		"\A3\Data_F_Warlords\Data\preview_empty.jpg",
		""
	], [
		"ClearVehicles",
		0,
		[],
		"Kick players from all vehicles",
		"\A3\Data_F_Warlords\Data\preview_empty.jpg",
		"This doesn't include you or your AI."
	], [
		"PruneMines",
		0,
		[],
		"Clear personal mines",
		"\A3\Data_F_Warlords\Data\preview_empty.jpg",
		"Deletes all deployed mines."
	], [
		"ResetVehicle",
		10,
		[],
		"Reset vehicle",
		"\A3\Data_F_Warlords\Data\preview_empty.jpg",
		"Reset vehicle. Must be within 15m and looking at the vehicle."
	], [
		"Camouflage",
		500,
		[],
		"Camouflage",
		"\A3\Data_F_Warlords\Data\preview_empty.jpg",
		"Camouflage your current position with tall plants. Disappears after 5 minutes."
	], [
		"CruiseMissiles",
		15000,
		[],
		"Call missile strike",
		"\A3\Data_F_Warlords\Data\preview_empty.jpg",
		"Call a volley of cruise missiles on your designation. Requires all targets (vehicles or infantry) to be on datalink."
	], [
		"WipeMap",
		0,
		[],
		"Wipe map",
		"\A3\Data_F_Warlords\Data\preview_empty.jpg",
		"Wipes all user-defined markers from your own map locally. This includes your own."
	], [
		"ControlCollaborator",
		2000,
		[],
		"Control collaborator",
		"\A3\Data_F_Warlords\Data\preview_empty.jpg",
		"Find and control a collaborator in the local population within 4km, that is not in the sector your team is attacking."
	], [
		"AIGetIn",
		0,
		[],
		"AI get in",
		"\A3\Data_F_Warlords\Data\preview_empty.jpg",
		"Your AI within 50m radius will be forced into the vehicle you are driving."
	], [
		"RemoveUnits",
		0,
		[],
		localize "STR_A3_WL_feature_dismiss_selected",
		"\A3\Data_F_Warlords\Data\preview_empty.jpg",
		""
	], [
		"BulkRemove",
		0,
		[],
		"Bulk remove",
		"\A3\Data_F_Warlords\Data\preview_empty.jpg",
		"Once activated, you will have 30 seconds in which any asset you remove will not prompt you for confirmation."
	], [
		"WelcomeScreen",
		0,
		[],
		localize "STR_WL_infoMenuInfo",
		"src\img\wl_logo_ca.paa",
		""
	]
];

#if WL_PERF_TEST
_strategyArr pushBack [
	"StressTestSector",
	0,
	[],
	"Stress test: assets in current sector",
	"\A3\Data_F_Warlords\Data\preview_empty.jpg",
	"Order up to 50 vehicles in current sector to test performance under stress."
];
_strategyArr pushBack [
	"StressTestMap",
	0,
	[],
	"Stress test: assets in every sector",
	"\A3\Data_F_Warlords\Data\preview_empty.jpg",
	"Order up to 5 vehicles in every sector to test performance under stress."
];
_strategyArr pushBack [
	"StressTestKillfeed",
	0,
	[],
	"Stress test: killfeed",
	"\A3\Data_F_Warlords\Data\preview_empty.jpg",
	"Add some random killfeed items."
];
_strategyArr pushBack [
	"StressTestSpawns",
	0,
	[],
	"Stress test: show sector spawns",
	"\A3\Data_F_Warlords\Data\preview_empty.jpg",
	"Show all possible sector spawns."
];
_strategyArr pushBack [
	"TestRebalance",
	0,
	[],
	"Test: rebalance me",
	"\A3\Data_F_Warlords\Data\preview_empty.jpg",
	"Rebalance me to the other team."
];
#endif

#if WL_FACTION_THREE_ENABLED
_strategyArr pushBack [
	"SwitchToGreen",
	0,
	[],
	"Switch to green",
	"\a3\data_f\flags\flag_green_co.paa",
	"Switch to Green side"
];
#endif

_strategyArr = [_strategyArr, [], { _x # 3 }, "ASCEND"] call BIS_fnc_sortBy;

private _strategyCategoryIndex = WL_REQUISITION_CATEGORIES find "Strategy";
if (_strategyCategoryIndex != -1) then {
	_purchaseable set [_strategyCategoryIndex, _strategyArr];
};

missionNamespace setVariable [format ["WL2_purchasable_%1", _side], _purchaseable];