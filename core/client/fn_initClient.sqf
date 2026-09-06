#include "includes.inc"
WL_LoadingState = 0;

#if WL_DEBUG_INIT
0 spawn {
	private _startTime = time;
	while { WL_LoadingState < 12 } do {
		uiSleep 2;
		diag_log format ["[Warlords Client] Loading %1 | %2", WL_LoadingState, serverTime];

		if (time - _startTime > 30) then {
			break;
		};
	};

	["main"] call BIS_fnc_endLoadingScreen;
};
#endif

waitUntil {
	!isNull player && { isPlayer player }
};

private _disallowList = getArray (missionConfigFile >> "adminFilter");
private _playerName = toLower (name player);
private _filteredText = _playerName;
{
    _filteredText = _filteredText regexReplace [_x, "\*\*\*"];
} forEach _disallowList;
if (_playerName != _filteredText) exitWith {
	[localize "STR_WL_badNameInfo", format ["Name: %1", _filteredText]] call WL2_fnc_exitToLobby;
};

WL_LoadingState = 1;
showScoretable 0;

addMissionEventHandler ["HandleChatMessage", {
	_this call WL2_fnc_handleChatMessages;	// intentional
}];

private _sidePickerState = civilian;
waitUntil {
	uiSleep 0.01;
	_sidePickerState = player getVariable ["WL2_sidePickerState", civilian];
	_sidePickerState != civilian
};

private _side = if (_sidePickerState == independent) then {
	call WL2_fnc_sidePicker
} else {
	_sidePickerState
};
BIS_WL_playerSide = _side;
BIS_WL_enemySide = (BIS_WL_competingSides - [_side]) # 0;

private _setupState = "";
waitUntil {
	uiSleep 0.001;
	_setupState = player getVariable ["WL2_playerSetupState", ""];
	_setupState != ""
};

if (_setupState == "Failed") exitWith {
	private _message = "Failed to create player group. Aborting. Rejoin from lobby.";
    [_message, "Initialization Failed"] call WL2_fnc_exitToLobby;
};

WL_LoadingState = 2;

private _uid = getPlayerUID player;
call WL2_fnc_varsInit;

WL_LoadingState = 3;

if !(BIS_WL_playerSide in BIS_WL_sidesArray) exitWith {
	["Your unit is not a Warlords competitor", "Warlords Mission Error."] call WL2_fnc_exitToLobby;
};

enableRadio true;
enableSentences true;
[true] call WL2_fnc_mutePlayer;
setCurrentChannel 1;
enableEnvironment [false, true];

WL_LoadingState = 4;

uiNamespace setVariable ["BIS_WL_purchaseMenuLastSelection", [0, 0, 0]];

private _settingsMap = missionProfileNamespace getVariable "WL2_settings";
if (isNil "_settingsMap") then {
	private _oldSettingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];
    missionProfileNamespace setVariable ["WL2_settings", +_oldSettingsMap];
	profileNamespace setVariable ["WL2_settings", nil];
	_settingsMap = missionProfileNamespace getVariable "WL2_settings";
};

private _savedLoadouts = missionProfileNamespace getVariable ["WL2_savedLoadouts", createHashMap];
private _savedLoadoutsWest = _savedLoadouts getOrDefault ["west", createHashMap];
private _savedLoadoutsEast = _savedLoadouts getOrDefault ["east", createHashMap];

for "_i" from 0 to 29 do {
	private _loadoutVarWest = format ["WLC_savedLoadout_west_%1", _i];
	private _loadoutVarEast = format ["WLC_savedLoadout_east_%1", _i];

	private _savedLoadoutWest = profileNamespace getVariable _loadoutVarWest;
	private _savedLoadoutEast = profileNamespace getVariable _loadoutVarEast;

	if (!isNil "_savedLoadoutWest") then {
		_savedLoadoutsWest set [_i, _savedLoadoutWest];
		_savedLoadouts set ["west", _savedLoadoutsWest];
		missionProfileNamespace setVariable ["WL2_savedLoadouts", _savedLoadouts];
		profileNamespace setVariable [_loadoutVarWest, nil];
	};

	if (!isNil "_savedLoadoutEast") then {
		_savedLoadoutsEast set [_i, _savedLoadoutEast];
		_savedLoadouts set ["east", _savedLoadoutsEast];
		missionProfileNamespace setVariable ["WL2_savedLoadouts", _savedLoadouts];
		profileNamespace setVariable [_loadoutVarEast, nil];
	};
};

private _badges = missionProfileNamespace getVariable "WL2_badges";
if (isNil "_badges") then {
	private _oldBadges = profileNamespace getVariable ["WL2_badges", createHashMap];
	missionProfileNamespace setVariable ["WL2_badges", +_oldBadges];
	profileNamespace setVariable ["WL2_badges", nil];
};

private _levelScore = missionProfileNamespace getVariable "WLC_Score";
if (isNil "_levelScore") then {
	private _oldLevelScore = profileNamespace getVariable ["WLC_Score", 0];
	missionProfileNamespace setVariable ["WLC_Score", _oldLevelScore];
	profileNamespace setVariable ["WLC_Score", nil];
};

saveMissionProfileNamespace;

WL_LoadingState = 5;

call WL2_fnc_sectorsInitClient;
WL_LoadingState = 6;

call WL2_fnc_updateSectorsData;
WL_LoadingState = 7;

{
	[_x, _x getVariable "BIS_WL_owner"] call WL2_fnc_sectorMarkerUpdate;
} forEach BIS_WL_allSectors;

if !(isServer) then {
	BIS_WL_playerSide call WL2_fnc_parsePurchaseList;
};
WL_LoadingState = 8;

0 spawn WL2_fnc_initHud;
0 spawn WL2_fnc_fastHudUpdate;
0 spawn {
	while {!BIS_WL_missionEnd} do {
		call WL2_fnc_teammatesAvailability;
		uiSleep 5;
	};
};

private _friendlyTargetMarker = "BIS_WL_targetFriendly";
private _enemyTargetMarker = "BIS_WL_targetEnemy";
createMarkerLocal [_friendlyTargetMarker, [0, 0, 0]];
createMarkerLocal [_enemyTargetMarker, [0, 0, 0]];
_friendlyTargetMarker setMarkerAlphaLocal 0;
_enemyTargetMarker setMarkerAlphaLocal 0;

call WL2_fnc_drawTargetMarker;

0 spawn WL2_fnc_clientEH;
call WL2_fnc_arsenalSetup;
WL_LoadingState = 9;

0 spawn {
	waitUntil {
		uiSleep 0.1;
		!isNull WL_CONTROL_MAP
	};
	WL_CONTROL_MAP ctrlMapAnimAdd [0, 0.35, (BIS_WL_playerSide call WL2_fnc_getSideBase)];
	ctrlMapAnimCommit WL_CONTROL_MAP;
};

WL_LoadingState = 10;

0 spawn {
	while { !BIS_WL_missionEnd } do {
		private _buyMenuDisplay = uiNamespace getVariable ["BIS_WL_purchaseMenuDisplay", displayNull];
		if (isNull _buyMenuDisplay) then {
			uiSleep 1;
			continue;
		};

		call WL2_fnc_purchaseMenuRefresh;
		uiSleep 0.5;
	};
};

0 spawn WL2_fnc_aiVehicleCrewHandler;
0 spawn WL2_fnc_sectorVoteClient;
0 spawn WL2_fnc_assetMapControl;
0 spawn WL2_fnc_mapIcons;
0 spawn APS_fnc_apsReloader;

[46] spawn GFE_fnc_earplugs;
WL_LoadingState = 11;

0 spawn WL2_fnc_announcerInit;

if !(isDedicated) then {
	[true] call WL2_fnc_spawnAtBase;
};

0 spawn {
	private _originalSpeaker = speaker player;
	private _settingsMap = missionProfileNamespace getVariable ["WL2_settings", createHashMap];
	while { !BIS_WL_missionEnd } do {
		uiSleep 5;
		private _noVoice = _settingsMap getOrDefault ["noVoiceSpeaker", false];
		if (_noVoice) then {
			player setSpeaker "NoVoice";
		} else {
			player setSpeaker _originalSpeaker;
		};
	};
};

0 spawn {
	private _ownedVehicleVar = format ["BIS_WL_ownedVehicles_%1", getPlayerUID player];
	while { !BIS_WL_missionEnd } do {
		private _vehicles = missionNamespace getVariable [_ownedVehicleVar, []];
		private _newVehicles = _vehicles select {
			_x == player || _x getVariable ["BIS_WL_ownerAsset", "123"] == getPlayerUID player
		};
		if !(player in _newVehicles) then {
			_newVehicles pushBack player;
		};
		if !(_vehicles isEqualTo _newVehicles) then {
			missionNamespace setVariable [_ownedVehicleVar, _newVehicles, [2, clientOwner]];
		};
		uiSleep 1;
	};
};

#if WL_FREE_MONEY
	player addAction ["+$50K", {
		[player, "50K"] remoteExec ["WL2_fnc_handleClientRequest", 2];
	}, [], -1000, false, false, "", "", 0];
#endif

#if WL_TEST_SERVER
	0 spawn {
		uiSleep 10;
		["Play Tester", true] call RWD_fnc_addBadge;
	};
#endif

#if WL_ZEUS_ENABLED
	{
		private _curator = _x;
		_curator addEventHandler ["CuratorObjectPlaced", {
			params ["_curator", "_entity"];
			[_entity] call WL2_fnc_newAssetHandle;
			{
				[_x] call WL2_fnc_newAssetHandle;
			} forEach (crew _entity);

			private _ownedVehicles = missionNamespace getVariable ["BIS_WL_ownedVehicles_server", []];
			_ownedVehicles pushBack _entity;
			missionNamespace setVariable ["BIS_WL_ownedVehicles_server", _ownedVehicles, true];
		}];
	} forEach allCurators;
#endif

private _spawnMenuText = format [
	"<t color='#00FFFF'>%1 (Key: %2)</t>",
	localize "STR_WL_spawnMenu",
	(actionKeysNames ["watch", 1, "Keyboard"]) regexReplace ["""", ""]
];
player addAction [_spawnMenuText, { 0 spawn SQD_fnc_initSquadMenu; }, [], -100, false, true, "watch", "", 0, true];

uiNamespace setVariable ["WL2_canBuy", true];
uiNamespace setVariable ["WL2_chatHistory", []];
uiNamespace setVariable ["WL2_timedPromptQueue", []];
uiNamespace setVariable ["WL2_HMDSettingProfileIndex", 0];

WL2_lastLoadout = getUnitLoadout player;
[player] call WLC_fnc_onRespawn;

call WL2_fnc_spectrumInterface;

call SQD_fnc_initClient;

call WL2_fnc_pingFixInit;

0 spawn MENU_fnc_settingsMenu;
0 spawn REP_fnc_playerDataRefresh;

0 spawn {
	while { !BIS_WL_missionEnd } do {
		{
			_x call WL2_fnc_uavConnectRefresh;
		} forEach allUnitsUAV;
		uiSleep 5;
	};
};

0 spawn WL2_fnc_handleEnemyCapture;
0 spawn WL2_fnc_combatAirClient;
0 spawn WL2_fnc_diaryItems;
0 spawn {
	uiSleep 5;
	[] call MENU_fnc_updateViewDistance;
};
0 spawn WL2_fnc_interceptAction;
0 spawn WL2_fnc_secureWreckAction;
0 spawn WL2_fnc_controlDroneActions;
if (!isServer) then {
	0 spawn WL2_fnc_cleanupCarrier;
};
0 spawn WL2_fnc_reviveAction;
0 spawn WL2_fnc_installAction;
0 spawn WL2_fnc_helmetInterface;
0 spawn WL2_fnc_repairActionUpdate;
0 spawn WL2_fnc_lockActionUpdate;

["Player", true] call RWD_fnc_addBadge;
player setVariable ["WL2_currentBadge", missionProfileNamespace getVariable ["WL2_currentBadge", "Player"], true];
0 spawn WL2_fnc_updateLevelDisplay;

0 spawn WL2_fnc_restrictedArea;
[false] spawn WL2_fnc_dumbMineHandler;

call WL2_fnc_buyMenuAction;
call WL2_fnc_demolishAction;
call WL2_fnc_rappelAction;
call WL2_fnc_hmdSettingsAction;

0 spawn WL2_fnc_createInfoMarkers;
0 spawn WL2_fnc_drawRegions;
0 spawn WL2_fnc_locationScanner;
0 spawn WL2_fnc_rewardCapture;
0 spawn WL2_fnc_ewarResult;

missionNamespace setVariable ["WL2_afkTimer", serverTime + WL_DURATION_AFKTIME];
0 spawn WL2_fnc_afk;
call WL2_fnc_afkAction;

uiNamespace setVariable ["WL2_cruiseMissileLockState", "NONE"];
uiNamespace setVariable ["WL2_guidMap", createHashMap];
uiNamespace setVariable ["WL2_scoreboardData", []];
uiNamespace setVariable ["WL2_damagedProjectiles", createHashMap];
uiNamespace setVariable ["WL2_damageSource", objNull];
uiNamespace setVariable ["WL2_damagedWeapon", nil];
uiNamespace setVariable ["WL2_surrenderWarningActive", false];

"deathInfo" cutFadeOut 0;
"missileCamera" cutFadeOut 0;
"SpectatorInfo" cutFadeOut 0;

0 spawn WL2_fnc_ammoConfigChange;
0 spawn DIS_fnc_setupTargetingMenu;
0 spawn WL2_fnc_refreshKillfeed;

// 0 spawn WL2_fnc_surveillance;

#if WL_WINTER_EVENT
[true] spawn WL2_fnc_pingSounds;
#endif

private _commMenuClasses = "true" configClasses (missionConfigFile >> "CfgCommunicationMenu");
{
	private _name = configName _x;
	[player, _name, nil, nil, ""] call BIS_fnc_addCommMenuItem;
} forEach _commMenuClasses;

0 spawn SQD_fnc_initSquadMenu;

private _additionalSubs = _settingsMap getOrDefault ["additionalSubs", false];
if !("additionalSubs" in _settingsMap) then {
	0 spawn {
		private _result = ["Subtitles", "Would you like to turn on additional subtitles for the hearing impaired? This can be turned on/off in settings.", "Yes", "No"] call WL2_fnc_prompt;
		private _settingsMap = missionProfileNamespace getVariable ["WL2_settings", createHashMap];
		_settingsMap set ["additionalSubs", _result];
	};
};

WL_LoadingState = 12;