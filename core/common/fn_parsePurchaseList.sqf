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
		"FTAirAssault",
		WL_COST_AIRASSAULT,
		[],
		localize "STR_WL_ftAirAssault",
		"\A3\EditorPreviews_F\Data\CfgVehicles\VR_Area_01_circle_4_grey_F.jpg",
		localize "STR_WL_ftAirAssaultInfo"
	], [
		"RespawnBagFT",
		0,
		[],
		localize "STR_WL_ftTent",
		"\A3\EditorPreviews_F\Data\CfgVehicles\Land_TentA_F.jpg",
		localize "STR_WL_ftTentInfo"
	], [
		"BuyStronghold",
		WL_COST_STRONGHOLD,
		[],
		localize "STR_WL_ftBuyStronghold",
		"\A3\EditorPreviews_F\Data\CfgVehicles\Land_Cargo_Tower_V3_F.jpg",
		localize "STR_WL_ftBuyStrongholdInfo"
	]
];

private _ftCategoryIndex = WL_REQUISITION_CATEGORIES find "Fast Travel";
if (_ftCategoryIndex != -1) then {
	_purchaseable set [_ftCategoryIndex, _fastTravelArr];
};

private _strategyArr = [
	[
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
		localize "STR_WL_kickPlayers",
		"\A3\Data_F_Warlords\Data\preview_empty.jpg",
		localize "STR_WL_kickPlayersInfo"
	], [
		"PruneMines",
		0,
		[],
		localize "STR_WL_clearPersonalExplosives",
		"\A3\Data_F_Warlords\Data\preview_empty.jpg",
		localize "STR_WL_clearPersonalExplosivesInfo"
	], [
		"ResetVehicle",
		0,
		[],
		localize "STR_WL_resetVehicle",
		"\A3\Data_F_Warlords\Data\preview_empty.jpg",
		localize "STR_WL_resetVehicleInfo"
	], [
		"SwitchToCollaborator",
		WL_COST_COLLABORATOR,
		[],
		localize "STR_WL_controlCollaborator",
		"\A3\Data_F_Warlords\Data\preview_empty.jpg",
		localize "STR_WL_controlCollaboratorInfo"
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
		localize "STR_WL_bulkRemove",
		"\A3\Data_F_Warlords\Data\preview_empty.jpg",
		localize "STR_WL_bulkRemoveInfo"
	], [
		"WelcomeScreen",
		0,
		[],
		localize "STR_WL_infoMenuInfo",
		"src\img\reduxlogosmall.paa",
		""
	], [
		"Surrender",
		0,
		[],
		localize "STR_WL_surrender",
		"\A3\Data_F_Warlords\Data\preview_scan.jpg",
		localize "STR_WL_surrenderInfo"
	], [
		"SeeChangelog",
		0,
		[],
		localize "STR_WL_seeChangelog",
		"\A3\Data_F_Warlords\Data\preview_scan.jpg",
		localize "STR_WL_seeChangelogInfo"
	]
];

#if WL_CRUISE_MISSILES
_strategyArr pushBack [
	"CruiseMissiles",
	15000,
	[],
	localize "STR_WL_callMissileStrike",
	"\A3\Data_F_Warlords\Data\preview_empty.jpg",
	localize "STR_WL_cruiseMissilesInfo"
];
#endif

#if WL_CAMOUFLAGE_ENABLED
_strategyArr pushBack [
	"Camouflage",
	500,
	[],
	localize "STR_WL_camouflage",
	"\A3\Data_F_Warlords\Data\preview_empty.jpg",
	localize "STR_WL_camouflageInfo"
];
#endif

#if WL_PERF_TEST
_strategyArr pushBack [
	"StressTestSector",
	0,
	[],
	localize "STR_WL_stressTestSector",
	"\A3\Data_F_Warlords\Data\preview_empty.jpg",
	localize "STR_WL_stressTestSectorInfo"
];
_strategyArr pushBack [
	"StressTestMap",
	0,
	[],
	localize "STR_WL_stressTestMap",
	"\A3\Data_F_Warlords\Data\preview_empty.jpg",
	localize "STR_WL_stressTestMapInfo"
];
_strategyArr pushBack [
	"StressTestKillfeed",
	0,
	[],
	localize "STR_WL_stressTestKillfeed",
	"\A3\Data_F_Warlords\Data\preview_empty.jpg",
	localize "STR_WL_stressTestKillfeedInfo"
];
_strategyArr pushBack [
	"StressTestSpawns",
	0,
	[],
	localize "STR_WL_stressTestSpawns",
	"\A3\Data_F_Warlords\Data\preview_empty.jpg",
	localize "STR_WL_stressTestSpawnsInfo"
];
_strategyArr pushBack [
	"TestRebalance",
	0,
	[],
	localize "STR_WL_testRebalance",
	"\A3\Data_F_Warlords\Data\preview_empty.jpg",
	localize "STR_WL_testRebalanceInfo"
];
#endif

#if WL_FACTION_THREE_ENABLED
_strategyArr pushBack [
	"SwitchToGreen",
	0,
	[],
	localize "STR_WL_switchToGreen",
	"\a3\data_f\flags\flag_green_co.paa",
	localize "STR_WL_switchToGreenInfo"
];
#endif

_strategyArr = [_strategyArr, [], { _x # 3 }, "ASCEND"] call BIS_fnc_sortBy;

private _strategyCategoryIndex = WL_REQUISITION_CATEGORIES find "Strategy";
if (_strategyCategoryIndex != -1) then {
	_purchaseable set [_strategyCategoryIndex, _strategyArr];
};

missionNamespace setVariable [format ["WL2_purchasable_%1", _side], _purchaseable];
