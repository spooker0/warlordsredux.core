class CfgFunctions {
	class APS {
		class Default {
			file = "src\scripts\APS";
			class active {};
			class dazzle {};
			class defineVehicles {};
			class deviceJammer {};
			class firedProjectile {};
			class getDirection {};
			class getMaxAmmo {};
			class hasCharges {};
			class lagProtection {};
			class lagProtectionServer {};
			class projectileStateUpdate {};
			class rearmAPS {};
			class registerVehicle {};
			class relDir2 {};
			class report {};
			class sead {};
			class setupProjectiles {};
			class serverHandleAPS {};
		};
	};
	class DIS {
		class Default {
			file = "src\scripts\DIS";
			class controlMunition {};
			class frag {};
			class maneuver {};
			class missileCamera {};
			class remoteMunition {};
			class startMissileCamera {};
			class tvMunition {};
		};
	};
	class FXR {
		class Default {
			file = "src\scripts\FXR";
			class closeReportMenu {};
			class openReportMenu {};
		};
	};
	class GFE {
		class Default {
			file = "src\scripts\GFE";
			class credits {};
			class earplugs {};
		};
	};
	class KST {
		class Default {
			file = "src\scripts\KST";
			class actions {};
			class explode {};
			class rocket {};
			class setParent {};
		};
	};
	class MRTM {
		class Default {
			file = "src\scripts\MRTM";
			class execCode {};
			class onChar {};
			class onSliderChanged {};
			class openDebugMenu {};
			class openMenu {};
			class setReturnValue {};
			class settingsInit {};
			class settingsMenu {};
			class updateSettings {};
			class updateViewDistance {};
		};
	};
	class POLL {
		class Default {
			file = "src\scripts\Poll";
			class chatCommand {};
			class openPoll {};
			class vote {};
		};
	};
	class SQD {
		class Default {
			file = "src\scripts\SQD";
			class client {};
			class initClient {};
			class initServer {};
			class menu {};
			class playerSelectionChanged {};
			class server {};
			class treeSelectionChanged {};
			class voice {};
		};
	};
	class WL2 {
		class Client {
			file = "src\core\client";
			class airburst {};
			class announcer {};
			class avTerminal {};
			class betty {};
			class clientEH {};
			class cpBalance {};
			class factionBasedClientInit {};
			class forfeitHandle {};
			class handleBuyMenuKeypress {};
			class handleKeypress {};
			class hintHandle {};
			class initClient {};
			class interceptAction {};
			class lagMessageDisplay {};
			class mineLimitHint {};
			class onPause {};
			class onPlayerRespawn {};
			class pingFix {};
			class pingFixInit {};
			class playerEventHandlers {};
			class prepareRappel {};
			class prompt {};
			class repackMagazines {};
			class restrictedArea {};
			class revive {};
			class rita {};
			class spectator {};
			class sideToFaction {};
			class spectrumInterface {};
			class teammatesAvailability {};
			class timer {};
			class triggerPurchase {};
			class updateLevelDisplay {};
			class wasMain {};
			class welcome {};
		};
		class ClientAction {
			file = "src\core\client\action";
			class arsenalSetup {};
			class attachVehicle {};
			class catapultAction {};
			class catapultActionEligibility {};
			class claimAction {};
			class claimEligibility {};
			class controlGunnerAction {};
			class controlGunnerEligibility {};
			class dazzlerAction {};
			class dazzlerToggle {};
			class dazzlerUpdate {};
			class demolishAction {};
			class demolishChargeAction {};
			class demolishEligibility {};
			class deployableAddAction {};
			class deployableEligibility {};
			class disarmAction {};
			class jammerAction {};
			class jammerToggle {};
			class jammerUpdate {};
			class logisticsAddAction {};
			class parachuteAction {};
			class parachuteSetup {};
			class radarOperateAction {};
			class radarOperateUpdate {};
			class radarRotateAction {};
			class radarRotateUpdate {};
			class rappelAction {};
			class rappelActionEligibility {};
			class rearmAction {};
			class remoteControlAction {};
			class removeAction {};
			class removeStronghold {};
			class repairAction {};
			class repairActionEligibility {};
			class respawnBagAction {};
			class reviveAction {};
			class scanner {};
			class scannerAction {};
			class setupForwardBaseAction {};
			class setupForwardBaseEligibility {};
			class setupForwardBaseMp {};
			class slingAddAction {};
			class stabilizeBoatAction {};
			class vehicleLockAction {};
			class vehicleLockUpdate {};
		};
		class ClientDraw {
			file = "src\core\client\draw";
			class drawAssetName {};
			class getDir {};
			class getPos {};
			class helmetInterface {};
			class iconColor {};
			class iconDrawGPS {};
			class iconDrawMap {};
			class iconSize {};
			class iconText {};
			class iconTextSectorScan {};
			class iconType {};
			class isScannerMunition {};
			class mapIcons {};
			class refreshCurrentTargetData {};
			class refreshOSD {};
			class sceneDrawHandle {};
			class setOSDEvent {};
			class setupUI {};
			class smoothText {};
			class uavJammer {};
		};
		class ClientKill {
			file = "src\core\client\kill";
			class askForgiveness {};
			class deathInfo {};
			class friendlyFireHandleClient {};
			class handleKillFeedUpdate {};
			class killRewardClient {};
			class updateKillFeed {};
		};
		class ClientMap {
			file = "src\core\client\map";
			class addTargetMapButton {};
			class assetButtonAccessControl {};
			class assetButtonDazzler {};
			class assetButtonJammer {};
			class assetButtonRadarOperate {};
			class assetButtonRadarRotate {};
			class assetMapButtons {};
			class assetMapControl {};
			class captureList {};
			class createInfoMarkers {};
			class deleteAssetFromMap {};
			class getRespawnMarkers {};
			class getSideBase {};
			class groupIconClickHandle {};
			class groupIconEnterHandle {};
			class groupIconLeaveHandle {};
			class handleEnemyCapture {};
			class handleSelectionState {};
			class mapButtonConditions {};
			class mapControlHandle {};
			class sectorCaptureStatus {};
			class sectorMapButtons {};
			class sectorMarkerUpdate {};
			class sectorOwnershipHandleClient {};
			class sectorRevealHandle {};
			class sectorScanHandle {};
			class sectorsInitClient {};
			class sectorVoteClient {};
			class sectorVoteDisplay {};
			class selectedTargetsHandle {};
			class targetResetHandle {};
			class targetResetHandleVote {};
			class targetSelected {};
			class updateSelectionState {};
		};
		class ClientOrder {
			file = "src\core\client\order";
			class cancelVehicleOrder {};
			class deployment {};
			class executeFastTravel {};
			class fastTravelConflictMarker {};
			class findStrongholdBuilding {};
			class orderAircraft {};
			class orderArsenal {};
			class orderFastTravel {};
			class orderForfeit {};
			class orderFTPodFT {};
			class orderFTVehicleFT {};
			class orderFundsTransfer {};
			class orderLastLoadout {};
			class orderNaval {};
			class orderSavedLoadout {};
			class orderStronghold {};
			class orderSectorScan {};
			class orderVehicle {};
			class requestPurchase {};
		};
		class ClientPurchase {
			file = "src\core\client\purchase";
			class checkAlliedPlayers {};
			class checkAssetLimit {};
			class checkBuyRespawn {};
			class checkCarrierLimits {};
			class checkCommTower {};
			class checkDead {};
			class checkFastTravelRespawn {};
			class checkFastTravelSL {};
			class checkFastTravelSquad {};
			class checkFunds {};
			class checkGreenSwitch {};
			class checkGroundVehicleDriver {};
			class checkIndependents {};
			class checkInfantryAvailable {};
			class checkInFriendlySector {};
			class checkInventoryOpen {};
			class checkIsOrdering {};
			class checkLastLoadout {};
			class checkNearbyEnemies {};
			class checkNoStronghold {};
			class checkParadropCooldown {};
			class checkPlayerInVehicle {};
			class checkRequirements {};
			class checkResetSectorTimer {};
			class checkResetVehicle {};
			class checkSavedLoadout {};
			class checkStrongholdFT {};
			class checkSelectedUnits {};
			class checkSurrender {};
			class checkTargetEnemyBase {};
			class checkTargetSelected {};
			class checkTargetUnlinked {};
			class checkTent {};
			class checkTentAction {};
			class checkUAVLimit {};
			class purchaseFromMenu {};
			class purchaseMenuAssetAvailability {};
			class purchaseMenuGetUIScale {};
			class purchaseMenuHandleDLC {};
			class purchaseMenuRefresh {};
			class purchaseMenuSetAssetDetails {};
			class purchaseMenuSetItemsList {};
		};
		class Common {
			file = "src\core\common";
			class accessControl {};
			class cleanupCarrier {};
			class findSpawnPositions {};
			class getAssetSide {};
			class getAssetTypeName {};
			class getMagazineName {};
			class getMoneySign {};
			class getVehicleWeapons {};
			class grieferCheck {};
			class handleInstigator {};
			class handleRespawnMarkers {};
			class income {};
			class initCommon {};
			class lastHitHandler {};
			class missionEndHandle {};
			class newAssetHandle {};
			class parsePurchaseList {};
			class prepareStronghold {};
			class protectStronghold {};
			class reloadOverride {};
			class scriptCollector {};
			class slingloadInit {};
			class sortSectorArrays {};
			class tablesSetUp {};
			class uavConnectRefresh {};
			class updateSectorArrays {};
			class varsInit {};
		};
		class Server {
			file = "src\core\server";
			class assetRelevanceCheck {};
			class attachDetach {};
			class calcImbalance {};
			class calculateEndResults {};
			class changeSectorOwnership {};
			class createUAVCrew {};
			class createVehicleCorrectly {};
			class detectNewPlayers {};
			class forfeitHandleServer {};
			class forgiveTeamkill {};
			class friendlyFireHandleServer {};
			class fundsDatabaseUpdate {};
			class fundsDatabaseWrite {};
			class garbageCollector {};
			class handleClientRequest {};
			class handleEntityRemoval {};
			class incomePayoff {};
			class initServer {};
			class killRewardHandle {};
			class lagMessageHandler {};
			class laserTracker {};
			class processRunways {};
			class selectTarget {};
			class serverEHs {};
			class setDazzlerState {};
			class setupNewPlayer {};
			class targetResetHandleServer {};
			class targetSelectionHandleServer {};
			class uavJammed {};
			class updateVehicleList {};
			class wlac {};
		};
		class ServerSector {
			file = "src\core\server\sector";
			class calcHomeBases {};
			class getCapValues {};
			class populateSector {};
			class populateCarrierSector {};
			class sectorCaptureHandle {};
			class sectorsInitServer {};
		};
		class ServerOrder {
			file = "src\core\server\order";
			class orderAir {};
			class orderGround {};
			class orderWater {};
			class processOrder {};
		};
	};
	class WLC {
		class Default {
			file = "src\scripts\WLC";
			class action {};
			class buildAmmo {};
			class buildAttachments {};
			class buildMenu {};
			class getLevelInfo {};
			class init {};
			class levelUp {};
			class onButtonSelect {};
			class onRespawn {};
			class onSelection {};
			class processSelection {};
			class setScore {};
			class updateItemCost {};
		};
	};
	class WLM {
		class WLM {
			file = "src\scripts\WLM\functions";
			class applyCustomization {};
			class applyLoadoutAircraft {};
			class applyLoadoutVehicle {};
			class applyTexture {};
			class applyPylon {};
			class applyVehicle {};
			class calculateFreeRearmEligibility {};
			class changeHorn {};
			class checkTurretLocality {};
			class constructAircraftPylons {};
			class constructPresetMenu {};
			class constructVehicleMagazine {};
			class getMagazineTooltip {};
			class initMenu {};
			class menuTextOverrides {};
			class moveSmokes {};
			class rearmAircraft {};
			class rearmVehicle {};
			class saveLoadout {};
			class selectLoadout {};
			class startRearmVehicle {};
			class switchUser {};
			class textureLists {};
			class textureSlots {};
			class wipePylonSaves {};
		};
	};

	class WLT {
		class Default {
			file = "src\scripts\WLT";
			class addNotification {};
			class handleParentTask {};
			class init {};
			class killRewardTaskHandle {};
			class taskComplete {};
			class taskEligible {};
			class taskStart {};
		};
	};
};