#include "includes.inc"
params ["_side"];

private _purchaseable = [_side] call WL2_fnc_parseAssetPurchases;
private _fastTravelArr = [
	[
		"FTPriority",
		0,
		[],
		"Fast travel to frontline",
		"\A3\Data_F_Warlords\Data\preview_ft_owned.jpg",
		"Fast travel to the team priority location, which is designated by squad leaders."
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
		"Fast travel air assault",
		"\A3\Data_F_Warlords\Data\preview_ft_conflict.jpg",
		"Attack the contested sector by dropping into it with a parachute."
	], [
		"FTParadropVehicle",
		WL_COST_PARADROP,
		[],
		"Fast travel vehicle paradrop",
		"\A3\Data_F_Warlords\Data\preview_ft_conflict.jpg",
		"Move your vehicle to a friendly sector from a helipad/airfield sector by paradropping it.<br/>Requirements:<br/>1. In an owned sector.<br/>2. In a vehicle as the driver.<br/>3. No enemies nearby.<br/>4. Cooldown: 5 minutes."
	], [
		"FTSquadLeader",
		WL_COST_FTSL,
		[],
		localize "STR_SQUADS_fastTravelToSquadLeader",
		"\A3\Data_F_Warlords\Data\preview_ft_conflict.jpg",
		localize "STR_SQUADS_fastTravelToSquadLeader"
	], [
		"RespawnBagFT",
		0,
		[],
		"Fast travel to tent",
		"\A3\Data_F_Warlords\Data\preview_ft_conflict.jpg",
		""
	], [
		"StrongholdFT",
		0,
		[],
		"Fast travel to sector stronghold",
		"\A3\Data_F_Warlords\Data\preview_ft_conflict.jpg",
		""
	], [
		"FTHome",
		0,
		[],
		"Fast travel to home sector",
		"\A3\Data_F_Warlords\Data\preview_ft_owned.jpg",
		""
	], [
		"BuyFOB",
		WL_COST_SUPPLIES,
		[],
		"Purchase forward base supplies",
		"\A3\Data_F_Warlords\Data\preview_ft_conflict.jpg",
		format ["Purchases equipment that can be airlifted or deployed into a forward position and setup into a base.<br/>Deploy requirements:<br/>1. Must be squad leader.<br/>2. Squad size >= 3.<br/>3. Outside of sectors.<br/>4. At least %1 away from other forward bases.<br/>5. Can have 4 total at once.<br/>Can also be used to add 20,000 supplies to an existing FOB.", WL_FOB_MIN_DISTANCE]
	], [
		"BuyStronghold",
		WL_COST_STRONGHOLD,
		[],
		"Purchase sector stronghold",
		"\A3\Data_F_Warlords\Data\preview_ft_conflict.jpg",
		"Fortifies the nearest building in your sector with a stronghold (one per sector at a time). This will replace the current stronghold if one exists. Strongholds provide a 5x bonus to infantry capture power in its small area, regardless of owner. Assets can be deployed onto strongholds. Strongholds can be used to speed up sector fortification process to reduce backcapping."
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
		"Combat air patrol",
		"\A3\Data_F_Warlords\Data\preview_scan.jpg",
		"Call in a temporary combat air patrol to assist your team's air defense over the selected airbase/helipad sector. Enemy aircraft that enter the marked map area are immediately spotted, and those flying above 1 km altitude will be given 45 seconds to leave before being automatically engaged by lethal air-to-air assets. Recommended to augment with short range air defenses and to use this opportunity to take off with air superiority assets."
	], [
		"Conscription",
		WL_COST_CONSCRIPT,
		[],
		"Conscript team",
		"\A3\Data_F_Warlords\Data\preview_scan.jpg",
		"Conscript team to the team priority point, giving everyone the option to fast travel there immediately."
	], [
		"FundsTransfer",
		WL_COST_FUNDTRANSFER,
		[],
		localize "STR_A3_WL_menu_moneytransfer",
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
		localize "STR_A3_WL_infoScreen",
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