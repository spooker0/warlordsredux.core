#include "includes.inc"
params ["_newUnit", "_oldUnit", "_respawn", "_respawnDelay"];

private _oldPosition = getPosASL _oldUnit;
private _oldOwnedSector = (BIS_WL_sectorsArray # 0) select {
	_oldPosition inArea (_x getVariable "objectAreaComplete")
};
if (count _oldOwnedSector > 0) then {
	private _oldSector = _oldOwnedSector # 0;
	private _oldSectorPreviousOwners = _oldSector getVariable ["BIS_WL_previousOwners", []];
	private _oldSectorVulnerable = count (_oldSectorPreviousOwners - [BIS_WL_playerSide]) > 0 || _oldSector == WL_TARGET_ENEMY;
	if (_oldSectorVulnerable) then {
		private _oldSectorDefenders = _oldSector getVariable ["WL2_defenders", 0];
		_oldSector setVariable ["WL2_defenders", (_oldSectorDefenders - 1) max 0, true];
	};
};

#if WL_WINTER_EVENT
[false] spawn WL2_fnc_pingSounds;
#endif

private _newGroup = group _newUnit;
if (leader _newGroup != _newUnit) then {
	[_newGroup, _newUnit] remoteExec ["selectLeader", groupOwner _newGroup];
};

#if WL_FACTION_THREE_ENABLED
if (side group player == independent) then {
	"respawn_guerrila" setMarkerPosLocal ([independent] call WL2_fnc_getSideBase);
};
#endif

#if WL_FREE_MONEY
	player addAction ["+$50K", {
		[player, "50K"] remoteExec ["WL2_fnc_handleClientRequest", 2];
	}, [], -1000, false, false, "", "", 0];
#endif

0 spawn WL2_fnc_reviveAction;
0 spawn WL2_fnc_installAction;

private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];
private _hideSpawnMenu = _settingsMap getOrDefault ["hideSpawnMenu", false];
if (!_hideSpawnMenu) then {
	player addAction [
		format ["<t color='#00FFFF'>%1 (Key: %2)</t>", "Spawn Menu", (actionKeysNames ["watch", 1, "Keyboard"]) regexReplace ["""", ""]],
		{ 0 spawn SQD_fnc_initSquadMenu; }, [], -100, false, false, "watch", "", 0
	];
};

private _playerSquad = ["getSquadForPlayer", [getPlayerID player]] call SQD_fnc_query;
if (count _playerSquad > 0) then {
	private _squadChannelId = _playerSquad getOrDefault ["channel", 0];
    if (_squadChannelId != 0) then {
        _squadChannelId radioChannelAdd [_newUnit];
    };
};

private _showPlayerUids = _settingsMap getOrDefault ["showPlayerUids", false];
uiNamespace setVariable ["WL2_showPlayerUids", _showPlayerUids];

uiNamespace setVariable ["WL2_canBuy", true];
if (isRemoteControlling player) then {
	player remoteControl objNull;
};

private _ownedVehiclesVar = format ["BIS_WL_ownedVehicles_%1", getPlayerUID player];
private _ownedVehicles = missionNamespace getVariable [_ownedVehiclesVar, []];
_ownedVehicles pushBack player;
missionNamespace setVariable [_ownedVehiclesVar, _ownedVehicles, [2, clientOwner]];

player setVariable ["BIS_WL_isOrdering", false, [2, clientOwner]];
player setVariable ["WL_lastHitter", objNull, 2];
player setVariable ["WL2_canAccessEW", true];
player setVariable ["WL2_acceptConscriptionTime", -1];
[] call WLC_fnc_onRespawn;

0 spawn MENU_fnc_settingsMenu;

0 spawn WL2_fnc_updateLevelDisplay;

player setVariable ["WL2_hasGrapple", 0];

0 spawn WL2_fnc_controlDroneActions;
call WL2_fnc_buyMenuAction;
call WL2_fnc_rappelAction;
call WL2_fnc_demolishAction;
call WL2_fnc_hmdSettingsAction;

0 spawn WL2_fnc_drawRadarName;
0 spawn WL2_fnc_interceptAction;	// just in case it's overridden
0 spawn WL2_fnc_secureWreckAction;

call WL2_fnc_afkAction;

BIS_WL_playerSide call WL2_fnc_parsePurchaseList;

0 spawn SQD_fnc_executeSpawn;

player setVariable ["WL2_unconscious", false, true];