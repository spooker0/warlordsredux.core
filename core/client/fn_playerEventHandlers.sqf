#include "includes.inc"
player addEventHandler ["HandleRating", {
	params ["_unit", "_rating"];
	0;
}];

player addEventHandler ["GetInMan", {
	params ["_unit", "_role", "_vehicle", "_turret"];
	if (_vehicle isKindOf "Air" && typeof _vehicle != "Steerable_Parachute_F") then {
		0 spawn WL2_fnc_betty;
	};
	if ((_vehicle getVariable ["BIS_WL_ownerAsset", "123"]) == getPlayerUID player) then {
		_vehicle setVariable ["BIS_WL_lastActive", 0];
	};
}];

player addEventHandler ["InventoryOpened",{
	params ["_unit","_container"];
	_override = false;
	_allUnitBackpackContainers = (player nearEntities ["Man", 50]) select {isPlayer _x} apply {backpackContainer _x};

	if (_container in _allUnitBackpackContainers) then {
		systemChat "Access denied!";
		_override = true;
	};
	_override;
}];

player addEventHandler ["Killed", {
	"RequestMenu_close" call WL2_fnc_setupUI;

	WL2_lastLoadout = getUnitLoadout player;

	private _connectedUAV = getConnectedUAV player;
	if (_connectedUAV != objNull) exitWith {
		player connectTerminalToUAV objNull;
	};
	player setVariable ["BIS_WL_isOrdering", false, [2, clientOwner]];

	private _canUse = player isUniformAllowed (uniform player);
	if !(_canUse) then {
		[format ["Player:%1, player's UID:%2: Uses a uniform from another faction: %3", player, getPlayerUID player, uniform player]] remoteExec ["diag_log", 2];
	};
	closeDialog 2;
}];

player addEventHandler ["HandleDamage", {
	_this call WL2_fnc_handlePlayerDamage;
}];

player addEventHandler ["GetOutMan", {
	params ["_unit", "_role", "_vehicle", "_turret", "_isEject"];
	[_unit] spawn {
		params ["_unit"];
		uiSleep 5;
		_unit allowDamage true;
	};
	if (((_vehicle getVariable "BIS_WL_ownerAsset") == (getPlayerUID player)) && (pricehash getOrDefault [typeOf _vehicle, 300] <= 200)) then {
		_vehicle setVariable ["BIS_WL_lastActive", serverTime + 600];
	};

	private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];
	if (_settingsMap getOrDefault ["deleteSmallTransports", true]) then {
		if (typeof _vehicle in [
			"B_Quadbike_01_F",
			"O_Quadbike_01_F",
			"C_Scooter_Transport_01_F"
		]) then {
			deleteVehicle _vehicle;
		};
	};
}];

player addEventHandler ["InventoryOpened", {
	params ["_unit", "_container", "_secondaryContainer"];

    private _access = [_container, player, "cargo"] call WL2_fnc_accessControl;
    if !(_access # 0) then {
        systemChat format ["Inventory locked. (%1)", _access # 1];
        playSoundUI ["AddItemFailed"];
        true;
    } else {
        false;
    };
}];

player addEventHandler ["Respawn", {
    params ["_unit", "_corpse"];

    private _voiceChannels = missionNamespace getVariable ["SQD_VoiceChannels", [-1, -1]];
    switch (side group _unit) do {
        case WEST: {
            _sideCustomChannel = _voiceChannels # 0;
            _sideCustomChannel radioChannelAdd [_unit];
        };
        case EAST: {
            _sideCustomChannel = _voiceChannels # 1;
            _sideCustomChannel radioChannelAdd [_unit];
        };
    };
}];

#if __GAME_BUILD__ > 153351
(group player) addEventHandler ["LeaderChanged", {
	params ["_group", "_newLeader"];
	if (_newLeader != player) then {
		{
			_x disableAI "COMMAND";
		} forEach (units _group);
	};
}];
#endif