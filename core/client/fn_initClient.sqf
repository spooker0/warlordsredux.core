#include "includes.inc"
WL_LoadingState = 0;
0 spawn {
	private _startTime = serverTime;

	private _stepText = "";
	private _totalLoadSteps = 12;
	waitUntil {
		uiSleep 0.1;
		serverTime - _startTime > 60 || WL_LoadingState >= _totalLoadSteps
	};

	if (WL_LoadingState < _totalLoadSteps) exitWith {
		["main"] call BIS_fnc_endLoadingScreen;
		"BlockScreen" setDebriefingText [
			"Load Failed",
			format ["It seems that client loading has failed to complete in time. It was stuck on %1. Please rejoin from the lobby. Thanks for understanding.", _stepText],
			"Loading failed. Please rejoin."
		];
		endMission "BlockScreen";
		forceEnd;
	};
};

waitUntil {
	!isNull player && {
		isPlayer player
	}
};
WL_LoadingState = 1;

private _uid = getPlayerUID player;
private _isAdmin = _uid in (getArray (missionConfigFile >> "adminIDs"));
private _isModerator = _uid in (getArray (missionConfigFile >> "moderatorIDs"));
private _isSpectator = _uid in (getArray (missionConfigFile >> "spectatorIDs"));

"client" call WL2_fnc_varsInit;
waitUntil {
	!(isNil "BIS_WL_playerSide")
};

#if WL_STOP_TEAM_SWITCH
if !(_isAdmin || _isModerator || _isSpectator) then {
	private _uid = getPlayerUID player;
	private _switch = format ["WL2_teamBlocked_%1", _uid];
	waitUntil {
		!isNil {
			missionNamespace getVariable _switch
		}
	};
	WL_LoadingState = 2;

	if (missionNamespace getVariable _switch) exitWith {
		["main"] call BIS_fnc_endLoadingScreen;
		"BlockScreen" setDebriefingText ["Switch Teams", localize "STR_A3_WL_switch_teams_info", localize "STR_A3_WL_switch_teams"];
		endMission "BlockScreen";
		forceEnd;
	};

	private _imbalanced = format ["WL2_balanceBlocked_%1", _uid];
	waitUntil {
		!isNil {
			missionNamespace getVariable _imbalanced
		}
	};
	WL_LoadingState = 3;

	if (missionNamespace getVariable _imbalanced) exitWith {
		["main"] call BIS_fnc_endLoadingScreen;
		"BlockScreen" setDebriefingText ["Switch Teams", "It seems that the teams are not balanced, please head back to the lobby and join the other team, Thank you.", "Teams are imbalanced."];
		endMission "BlockScreen";
		forceEnd;
	};

	private _text = toLower (name player);
	private _list = getArray (missionConfigFile >> "adminFilter");
	if ((_list findIf {
		[_x, _text] call BIS_fnc_inString
	}) != -1) exitWith {
		["main"] call BIS_fnc_endLoadingScreen;
		"BlockScreen" setDebriefingText ["Admin", localize "STR_A3_nameFilter_info", localize "STR_A3_nameFilter"];
		endMission "BlockScreen";
		forceEnd;
	};
};
#endif

WL_LoadingState = 4;

if !(BIS_WL_playerSide in BIS_WL_sidesArray) exitWith {
	["main"] call BIS_fnc_endLoadingScreen;
	"BlockScreen" setDebriefingText ["Error", "Your unit is not a Warlords competitor", "Warlords Mission Error."];
	endMission "BlockScreen";
	forceEnd;
};

enableRadio true;
enableSentences true;
[true] call WL2_fnc_mutePlayer;
setCurrentChannel 1;
enableEnvironment [false, true];

WL_LoadingState = 5;

uiNamespace setVariable ["BIS_WL_purchaseMenuLastSelection", [0, 0, 0]];
uiNamespace setVariable ["activeControls", []];
uiNamespace setVariable ["control", 10000];

private _settingsMap = profileNamespace getVariable "WL2_settings";
if (isNil "_settingsMap") then {
    profileNamespace setVariable ["WL2_settings", createHashMap];
};

WL_LoadingState = 6;

call WL2_fnc_sectorsInitClient;
WL_LoadingState = 7;

["client", true] call WL2_fnc_updateSectorArrays;
WL_LoadingState = 8;

{
	[_x, _x getVariable "BIS_WL_owner"] call WL2_fnc_sectorMarkerUpdate;
} forEach BIS_WL_allSectors;

if !(isServer) then {
	BIS_WL_playerSide call WL2_fnc_parsePurchaseList;
};
WL_LoadingState = 9;

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
WL_LoadingState = 10;

0 spawn {
	waitUntil {
		uiSleep 0.1;
		!isNull (uiNamespace getVariable ["BIS_WL_mapControl", controlNull])
	};
	(uiNamespace getVariable ["BIS_WL_mapControl", controlNull]) ctrlMapAnimAdd [0, 0.35, (BIS_WL_playerSide call WL2_fnc_getSideBase)];
	ctrlMapAnimCommit (uiNamespace getVariable ["BIS_WL_mapControl", controlNull]);
};

{
	_x setMarkerAlphaLocal 0
} forEach BIS_WL_sectorLinks;

WL_LoadingState = 11;

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
WL_LoadingState = 12;

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
		{
			private _lastActiveTime = _x getVariable ["BIS_WL_lastActive", 0];
			if (_lastActiveTime < serverTime && _lastActiveTime > 1 && count (crew _x) == 0) then {
				deleteVehicle _x;
			};
		} forEach _vehicles;

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

if !(["(EU) #11", serverName] call BIS_fnc_inString) then {
	player addAction [
		"+$10K",
		{
			[player, "10K"] remoteExec ["WL2_fnc_handleClientRequest", 2];
		}
	];

	0 spawn {
		uiSleep 10;
		["Play Tester", true] call RWD_fnc_addBadge;
	};

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
};

private _squadActionText = format ["<t color='#00FFFF'>%1</t>", localize "STR_SQUADS_squads"];
private _squadActionId = player addAction[_squadActionText, {
	0 spawn SQD_fnc_menu
}, [], -100, false, false, "", "", 0];
player setUserActionText [_squadActionId, _squadActionText, "<img size='2' image='\a3\ui_f\data\igui\cfg\simpletasks\types\meet_ca.paa'/>"];

uiNamespace setVariable ["WL2_canBuy", true];
uiNamespace setVariable ["WL2_chatHistory", []];
uiNamespace setVariable ["WL2_modOverrideUid", ""];

WL2_lastLoadout = getUnitLoadout player;
[player, true] call WLC_fnc_onRespawn;
[] spawn WL2_fnc_factionBasedClientInit;
0 spawn WL2_fnc_captureDisplay;
0 spawn WL2_fnc_mineLimitHint;

call WL2_fnc_spectrumInterface;

call SQD_fnc_initClient;

call WL2_fnc_pingFixInit;

0 spawn MENU_fnc_settingsMenu;
0 spawn MENU_fnc_playerDataRefresh;

missionNamespace setVariable [format ["BIS_WL2_minesDB_%1", getPlayerUID player],
	createHashMapFromArray [
		// ***Automatic mines***/
		["APERSMine_Range_Ammo", [10, []]],
		["APERSTripMine_Wire_Ammo", [10, []]],
		["APERSBoundingMine_Range_Ammo", [10, []]],
		["ATMine_Range_Ammo", [10, []]],
		["SLAMDirectionalMine_Wire_Ammo", [10, []]],
		// ***Manually Detonated***/
		["ClaymoreDirectionalMine_Remote_Ammo", [5, []]],
		["SatchelCharge_Remote_Ammo", [5, []]],
		["DemoCharge_Remote_Ammo", [5, []]]
		// ***Blacklisted***/
		/*
			["APERSMineDispenser_Mine_Ammo", [0, []]],
			["IEDUrbanSmall_Remote_Ammo", [0, []]],
			["IEDLandSmall_Remote_Ammo", [0, []]],
			["IEDUrbanBig_Remote_Ammo", [0, []]],
			["IEDLandBig_Remote_Ammo", [0, []]]
		*/
	],
	[2, clientOwner]
];

0 spawn {
	while { !BIS_WL_missionEnd } do {
		{
			_x call WL2_fnc_uavConnectRefresh;
		} forEach allUnitsUAV;
		uiSleep 5;
	};
};

player spawn APS_fnc_setupProjectiles;
0 spawn WL2_fnc_handleSelectionState;
0 spawn WL2_fnc_handleEnemyCapture;
0 spawn WL2_fnc_killHistory;
0 spawn {
	uiSleep 5;
	[] call MENU_fnc_updateViewDistance;
};
0 spawn WL2_fnc_interceptAction;
call WL2_fnc_controlUAVAction;
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

call POLL_fnc_pollAction;

missionNamespace setVariable ["WL2_afkTimer", serverTime + WL_DURATION_AFKTIME];
0 spawn WL2_fnc_afk;
call WL2_fnc_afkAction;

uiNamespace setVariable ["WL2_cruiseMissileLockState", "NONE"];
uiNamespace setVariable ["WL2_guidMap", createHashMap];
uiNamespace setVariable ["WL2_scoreboardData", []];
uiNamespace setVariable ["WL2_damagedProjectiles", createHashMap];

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