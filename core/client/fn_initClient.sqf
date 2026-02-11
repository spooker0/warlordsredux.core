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
	!isNull player && {
		isPlayer player
	}
};

private _text = toLower (name player);
private _list = getArray (missionConfigFile >> "adminFilter");
if ((_list findIf {
	[_x, _text] call BIS_fnc_inString
}) != -1) exitWith {
	[localize "STR_WL_badNameInfo", localize "STR_WL_badNameInfo"] call WL2_fnc_exitToLobby;
};

WL_LoadingState = 1;

private _setupState = "";
waitUntil {
	uiSleep 0.001;
	_setupState = player getVariable ["WL2_playerSetupState", ""];
	_setupState != ""
};

if (_setupState == "Teamlocked") exitWith {
	private _lockTeamName = if (side group player == west) then { "OPFOR" } else { "BLUFOR" };
    private _message = format ["You are locked to %1. Rejoin from lobby.", _lockTeamName];
    [_message, "Team Locked"] call WL2_fnc_exitToLobby;
};

if (_setupState == "Imbalance") exitWith {
	private _message = "Teams are imbalanced. Rejoin from lobby.";
	[_message, "Team Imbalance"] call WL2_fnc_exitToLobby;
};

WL_LoadingState = 2;

private _uid = getPlayerUID player;

"client" call WL2_fnc_varsInit;

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
uiNamespace setVariable ["activeControls", []];
uiNamespace setVariable ["control", 10000];

private _settingsMap = profileNamespace getVariable "WL2_settings";
if (isNil "_settingsMap") then {
    profileNamespace setVariable ["WL2_settings", createHashMap];
};

WL_LoadingState = 5;

call WL2_fnc_sectorsInitClient;
WL_LoadingState = 6;

["client", true] call WL2_fnc_updateSectorArrays;
WL_LoadingState = 7;

{
	[_x, _x getVariable "BIS_WL_owner"] call WL2_fnc_sectorMarkerUpdate;
} forEach BIS_WL_allSectors;

if !(isServer) then {
	BIS_WL_playerSide call WL2_fnc_parsePurchaseList;
};
WL_LoadingState = 8;

0 spawn WL2_fnc_initHud;
0 spawn {
	while {!BIS_WL_missionEnd} do {
		uiSleep 5;
		call WL2_fnc_teammatesAvailability;
	};
};

_mrkrTargetEnemy = createMarkerLocal ["BIS_WL_targetEnemy", position (BIS_WL_enemySide call WL2_fnc_getSideBase)];
_mrkrTargetEnemy setMarkerColorLocal BIS_WL_colorMarkerEnemy;
_mrkrTargetFriendly = createMarkerLocal ["BIS_WL_targetFriendly", position (BIS_WL_playerSide call WL2_fnc_getSideBase)];
_mrkrTargetFriendly setMarkerColorLocal BIS_WL_colorMarkerFriendly;

{
	_x setMarkerAlphaLocal 0;
	_x setMarkerSizeLocal [2, 2];
	_x setMarkerTypeLocal "selector_selectedMission";
} forEach [_mrkrTargetEnemy, _mrkrTargetFriendly];

0 spawn WL2_fnc_clientEH;
call WL2_fnc_arsenalSetup;
WL_LoadingState = 9;

0 spawn {
	waitUntil {
		uiSleep 0.1;
		!isNull (uiNamespace getVariable ["BIS_WL_mapControl", controlNull])
	};
	(uiNamespace getVariable ["BIS_WL_mapControl", controlNull]) ctrlMapAnimAdd [0, 0.35, (BIS_WL_playerSide call WL2_fnc_getSideBase)];
	ctrlMapAnimCommit (uiNamespace getVariable ["BIS_WL_mapControl", controlNull]);
};

WL_LoadingState = 10;

0 spawn WL2_fnc_repackMagazines;

0 spawn {
	_uid = getPlayerUID player;
	_selectedCnt = count ((groupSelectedUnits player) select {
		_x != player && {
			(_x getVariable ["BIS_WL_ownerAsset", "123"]) == _uid
		}
	});
	while { !BIS_WL_missionEnd } do {
		waitUntil {
			uiSleep 1;
			count ((groupSelectedUnits player) select {
				_x != player && {
					(_x getVariable ["BIS_WL_ownerAsset", "123"]) == _uid
				}
			}) != _selectedCnt
		};
		_selectedCnt = count ((groupSelectedUnits player) select {
			_x != player && {
				(_x getVariable ["BIS_WL_ownerAsset", "123"]) == _uid
			}
		});
		call WL2_fnc_purchaseMenuRefresh;
	};
};

0 spawn WL2_fnc_selectedTargetsHandle;
0 spawn WL2_fnc_sectorVoteClient;
0 spawn WL2_fnc_assetMapControl;
0 spawn WL2_fnc_mapIcons;

[46] spawn GFE_fnc_earplugs;
WL_LoadingState = 11;

0 spawn WL2_fnc_announcerInit;

if !(isDedicated) then {
	[true] call WL2_fnc_spawnAtBase;
};

0 spawn {
	WL_ORIGINAL_SPEAKER = speaker player;
	private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];
	while { !BIS_WL_missionEnd } do {
		uiSleep 5;
		private _noVoice = _settingsMap getOrDefault ["noVoiceSpeaker", false];
		if (_noVoice) then {
			player setSpeaker "NoVoice";
		} else {
			player setSpeaker WL_ORIGINAL_SPEAKER;
		};
	};
};

0 spawn {
	private _ownedVehicleVar = format ["BIS_WL_ownedVehicles_%1", getPlayerUID player];
	while { !BIS_WL_missionEnd } do {
		private _vehicles = missionNamespace getVariable [_ownedVehicleVar, []];
		private _newVehicles = _vehicles select {
			alive _x
		} select {
			_x == player || _x getVariable ["BIS_WL_ownerAsset", "123"] == getPlayerUID player
		};
		if !(_vehicles isEqualTo _newVehicles) then {
			missionNamespace setVariable [_ownedVehicleVar, _newVehicles, [2, clientOwner]];
		};
		uiSleep 10;
	};
};

#if WL_FREE_MONEY
	player addAction ["+$50K", {
		[player, "50K"] remoteExec ["WL2_fnc_handleClientRequest", 2];
	}];
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

private _squadActionText = format ["<t color='#00FFFF'>%1</t>", localize "STR_WL_squads"];
private _squadActionId = player addAction[_squadActionText, {
	0 spawn SQD_fnc_menu
}, [], -100, false, false, "", "", 0];
player setUserActionText [_squadActionId, _squadActionText, "<img size='2' image='\a3\ui_f\data\igui\cfg\simpletasks\types\meet_ca.paa'/>"];

uiNamespace setVariable ["WL2_canBuy", true];
uiNamespace setVariable ["WL2_chatHistory", []];
uiNamespace setVariable ["WL2_modOverrideUid", ""];
uiNamespace setVariable ["WL2_currentNotification", []];

WL2_lastLoadout = getUnitLoadout player;
[player, true] call WLC_fnc_onRespawn;
0 spawn WL2_fnc_captureDisplay;

call WL2_fnc_spectrumInterface;

call SQD_fnc_initClient;

call WL2_fnc_pingFixInit;

0 spawn MENU_fnc_settingsMenu;
0 spawn MENU_fnc_playerDataRefresh;

0 spawn {
	while { !BIS_WL_missionEnd } do {
		{
			_x call WL2_fnc_uavConnectRefresh;
		} forEach allUnitsUAV;
		uiSleep 5;
	};
};

0 spawn WL2_fnc_handleSelectionState;
0 spawn WL2_fnc_handleEnemyCapture;
0 spawn WL2_fnc_combatAirClient;
0 spawn WL2_fnc_killHistory;
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
0 spawn WL2_fnc_helmetInterface;
0 spawn WL2_fnc_repairActionUpdate;
0 spawn WL2_fnc_lockActionUpdate;
call WL2_fnc_vehicleManagerAction;

["Player", true] call RWD_fnc_addBadge;
player setVariable ["WL2_currentBadge", profileNamespace getVariable ["WL2_currentBadge", "Player"], true];
0 spawn WL2_fnc_updateLevelDisplay;

0 spawn WL2_fnc_restrictedArea;

call WL2_fnc_buyMenuAction;
call WL2_fnc_demolishAction;
call WL2_fnc_rappelAction;
call WL2_fnc_hmdSettingsAction;

0 spawn WL2_fnc_createInfoMarkers;
0 spawn WL2_fnc_drawRadarName;
0 spawn WL2_fnc_locationScanner;
0 spawn WL2_fnc_rewardCapture;

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
player setVariable ["WL2_canSecure", true, true];

showScoretable 0;
"deathInfo" cutFadeOut 0;
"missileCamera" cutFadeOut 0;

0 spawn WL2_fnc_ammoConfigChange;
0 spawn DIS_fnc_setupTargetingMenu;
0 spawn WL2_fnc_refreshKillfeed;

private _display = uiNamespace getVariable ["RscWLHintMenu", displayNull];
if (isNull _display) then {
    "hintLayer" cutRsc ["RscWLHintMenu", "PLAIN", -1, true, true];
    _display = uiNamespace getVariable "RscWLHintMenu";
};
private _texture = _display displayCtrl 5502;
_texture ctrlAddEventHandler ["PageLoaded", {
    params ["_texture"];
	[localize "STR_A3_WL_popup_init"] call WL2_fnc_smoothText;
}];

private _ownedVehiclesVar = format ["BIS_WL_ownedVehicles_%1", getPlayerUID player];
private _ownedVehicles = missionNamespace getVariable [_ownedVehiclesVar, []];
_ownedVehicles pushBack player;
missionNamespace setVariable [_ownedVehiclesVar, _ownedVehicles, [2, clientOwner]];

#if WL_WINTER_EVENT
[true] spawn WL2_fnc_pingSounds;
#endif

private _showWelcomeMenu = _settingsMap getOrDefault ["showWelcomeMenu", true];
if (_showWelcomeMenu) then {
	0 spawn WL2_fnc_welcome;
};

WL_LoadingState = 12;