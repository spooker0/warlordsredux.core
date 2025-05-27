#include "..\warlords_constants.inc"

params ["_newUnit", "_oldUnit", "_respawn", "_respawnDelay"];

private _newGroup = group _newUnit;
if (leader _newGroup != _newUnit) then {
	[_newGroup, _newUnit] remoteExec ["selectLeader", groupOwner _newGroup];
};

{
	_x enableAI "ALL";
} forEach (units _newGroup);
enableSentences true;

#if WL_FACTION_THREE_ENABLED
if (side group player == independent) then {
	"respawn_guerrila" setMarkerPosLocal ([independent] call WL2_fnc_getSideBase);
};
#endif

private _ownedVehiclesVar = format ["BIS_WL_ownedVehicles_%1", getPlayerUID _newUnit];
private _ownedVehicles = missionNamespace getVariable [_ownedVehiclesVar, []];
private _newOwnedVehicles = _ownedVehicles select { alive _x };
if !(_ownedVehicles isEqualTo _newOwnedVehicles) then {
	missionNamespace setVariable [_ownedVehiclesVar, _newOwnedVehicles, [2, clientOwner]];
};

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
	private _squadActionId = player addAction[_squadActionText, { [true] call SQD_fnc_menu }, [], -100, false, false, "", ""];
	player setUserActionText [_squadActionId, _squadActionText, "<img size='2' image='\a3\ui_f\data\igui\cfg\simpletasks\types\meet_ca.paa'/>"];
};

uiNamespace setVariable ["WL2_canBuy", true];
if (isRemoteControlling player) then {
	player remoteControl objNull;
};

player setVariable ["BIS_WL_isOrdering", false, [2, clientOwner]];
[] call WLC_fnc_onRespawn;
[] call WL2_fnc_factionBasedClientInit;

0 spawn MENU_fnc_settingsMenu;

player spawn APS_fnc_setupProjectiles;

0 spawn WL2_fnc_updateLevelDisplay;

if (player getVariable ["WL_hasGoggles", false]) then {
	player addGoggles "G_Tactical_Clear";
} else {
	removeGoggles player;
};

call WL2_fnc_rappelAction;
call WL2_fnc_demolishAction;
call WL2_fnc_disarmAction;

0 spawn WL2_fnc_drawRadarName;

call POLL_fnc_pollAction;

0 spawn WL2_fnc_afk;
