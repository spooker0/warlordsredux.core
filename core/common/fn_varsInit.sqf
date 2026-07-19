#include "includes.inc"

BIS_WL_playerSide = side group player;
BIS_WL_sidesArray = [west, east, independent];
BIS_WL_competingSides = [west, east];
BIS_WL_enemySide = (BIS_WL_competingSides - [BIS_WL_playerSide]) # 0;
BIS_WL_missionEnd = false;
BIS_WL_westOwnedVehicles = [];
BIS_WL_eastOwnedVehicles = [];
BIS_WL_guerOwnedVehicles = [];
BIS_WL_colorMarkerFriendly = ["colorBLUFOR", "colorOPFOR", "colorIndependent"] # (BIS_WL_sidesArray find BIS_WL_playerSide);
BIS_WL_colorMarkerEnemy = ["colorBLUFOR", "colorOPFOR", "colorIndependent"] # (BIS_WL_sidesArray find BIS_WL_enemySide);
BIS_WL_targetVote = objNull;
BIS_WL_matesAvailable = 0;
BIS_WL_colorsArray = [
	[profileNamespace getVariable ["Map_BLUFOR_R", 0], profileNamespace getVariable ["Map_BLUFOR_G", 1], profileNamespace getVariable ["Map_BLUFOR_B", 1], profileNamespace getVariable ["Map_BLUFOR_A", 0.8]],
	[profileNamespace getVariable ["Map_OPFOR_R", 0], profileNamespace getVariable ["Map_OPFOR_G", 1], profileNamespace getVariable ["Map_OPFOR_B", 1], profileNamespace getVariable ["Map_OPFOR_A", 0.8]],
	[profileNamespace getVariable ["Map_Independent_R", 0], profileNamespace getVariable ["Map_Independent_G", 1], profileNamespace getVariable ["Map_Independent_B", 1], profileNamespace getVariable ["Map_Independent_A", 0.8]],
	[profileNamespace getVariable ["Map_Unknown_R", 0], profileNamespace getVariable ["Map_Unknown_G", 1], profileNamespace getVariable ["Map_Unknown_B", 1], profileNamespace getVariable ["Map_Unknown_A", 0.8]]
];
BIS_WL_colorFriendly = BIS_WL_colorsArray # (BIS_WL_sidesArray find BIS_WL_playerSide);
BIS_WL_highlightedSector = objNull;
WL_MoneySign = [BIS_WL_playerSide] call WL2_fnc_getMoneySign;
WL_gearKeyPressed = false;
WL_AssetActionTargets = [];
WL_SectorActionTarget = objNull;
WL_SectorActionTargetActive = false;
WL_GEAR_BUY_MENU = false;
WL_TEMP_BUY_MENU = false;
WL_VotePhase = 0;
WL_HelmetInterface = 0;
WL_SpectrumInterface = false;
WL_IsSpectator = false;
WL_IsReplaying = false;
WL2_destroyerOutlineMarkers = [];
WL2_lastLoadout = [];