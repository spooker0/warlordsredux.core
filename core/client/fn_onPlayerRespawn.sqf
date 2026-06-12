#include "includes.inc"
params ["_newUnit", "_oldUnit", "_respawn", "_respawnDelay"];

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

player addAction [
	format ["<t color='#00FFFF'>%1 (Key: %2)</t>", "Spawn Menu", (actionKeysNames ["watch", 1, "Keyboard"]) regexReplace ["""", ""]],
	{ 0 spawn SQD_fnc_initSquadMenu; }, [], -100, false, true, "watch", "", 0, true
];

private _playerSquad = ["getSquadForPlayer", [getPlayerID player]] call SQD_fnc_query;
if (count _playerSquad > 0) then {
	private _squadChannelId = _playerSquad getOrDefault ["channel", 0];
    if (_squadChannelId != 0) then {
        _squadChannelId radioChannelAdd [_newUnit];
    };
};

private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];
private _showPlayerUids = _settingsMap getOrDefault ["showPlayerUids", false];
uiNamespace setVariable ["WL2_showPlayerUids", _showPlayerUids];

uiNamespace setVariable ["WL2_canBuy", true];
if (isRemoteControlling player) then {
	player remoteControl objNull;
};

private _playerUid = getPlayerUID player;
private _ownedVehiclesVar = format ["BIS_WL_ownedVehicles_%1", _playerUid];
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

private _ownedExplosiveVar = format ["WL2_ownedExplosives_%1", _playerUid];
private _ownedMineVar = format ["WL2_ownedMines_%1", _playerUid];
private _ownedExplosives = missionNamespace getVariable [_ownedExplosiveVar, []];
private _ownedMines = missionNamespace getVariable [_ownedMineVar, []];
{
	if (alive _x) then {
		player addOwnedMine _x;
	};
} forEach _ownedExplosives;
{
	if (alive _x) then {
		player addOwnedMine _x;
	};
} forEach _ownedMines;

player setVariable ["WL2_unconscious", false, true];