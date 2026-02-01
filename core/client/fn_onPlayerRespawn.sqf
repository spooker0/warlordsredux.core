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

if !(["(EU) #11", serverName] call BIS_fnc_inString) then {
	player addAction [
		"+$10K",
		{[player, "10K"] remoteExec ["WL2_fnc_handleClientRequest", 2];}
	];
};

0 spawn WL2_fnc_reviveAction;

private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];
private _hideSquadMenu = _settingsMap getOrDefault ["hideSquadMenu", false];
if (!_hideSquadMenu) then {
	private _squadActionText = format ["<t color='#00FFFF'>%1</t>", localize "STR_SQUADS_squads"];
	private _squadActionId = player addAction[_squadActionText, { 0 spawn SQD_fnc_menu }, [], -100, false, false, "", "", 0];
	player setUserActionText [_squadActionId, _squadActionText, "<img size='2' image='\a3\ui_f\data\igui\cfg\simpletasks\types\meet_ca.paa'/>"];
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
[] call WLC_fnc_onRespawn;

0 spawn MENU_fnc_settingsMenu;

0 spawn WL2_fnc_updateLevelDisplay;

player setVariable ["WL2_hasGrapple", 0];

0 spawn WL2_fnc_controlDroneActions;
call WL2_fnc_buyMenuAction;
call WL2_fnc_vehicleManagerAction;
call WL2_fnc_rappelAction;
call WL2_fnc_demolishAction;
call WL2_fnc_hmdSettingsAction;

0 spawn WL2_fnc_drawRadarName;
0 spawn WL2_fnc_interceptAction;	// just in case it's overridden

call POLL_fnc_pollAction;
call WL2_fnc_afkAction;

BIS_WL_playerSide call WL2_fnc_parsePurchaseList;

[false] call WL2_fnc_spawnAtBase;

player setVariable ["WL2_unconscious", false, true];