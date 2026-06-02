#include "includes.inc"
player addEventHandler ["HandleRating", {
	params ["_unit", "_rating"];
	0;
}];

player addEventHandler ["GetInMan", {
	params ["_unit", "_role", "_vehicle", "_turret"];
	if (_vehicle isKindOf "Air" && typeof _vehicle != "Steerable_Parachute_F") then {
		0 spawn WL2_fnc_betty;

		private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];
		private _defaultOffVtolAuto = _settingsMap getOrDefault ["defaultOffVtolAuto", false];
		if (_defaultOffVtolAuto) then {
			_unit action ["VTOLVectoring", _vehicle];
		};
	};
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

	private _vehicleOwnerUid = _vehicle getVariable ["BIS_WL_ownerAsset", "123"];
	if (_vehicleOwnerUid != getPlayerUID player) exitWith {};

	private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];
	if (_settingsMap getOrDefault ["deleteSmallTransports", true]) then {
		if (typeof _vehicle in WL_CLEANUP_TRANSPORTS) then {
			deleteVehicle _vehicle;
		};
	};
}];

player addEventHandler ["InventoryOpened", {
	params ["_unit", "_container", "_secondaryContainer"];

    private _access = [_container, player, "cargo"] call WL2_fnc_accessControl;
    if !(_access # 0) then {
        [format ["Inventory locked. (%1)", _access # 1]] call WL2_fnc_smoothText;
        playSoundUI ["AddItemFailed"];
        true;
    } else {
        false;
    };
}];

(group player) addEventHandler ["CommandChanged", {
	_this spawn {
		params ["_group", "_newCommand"];
		if (_newCommand != "GET IN") exitWith {};

		uiSleep 1;

		private _canMoveIn = {
			params ["_vehicle", "_person"];
			if (isPlayer _person) exitWith { false };
			private _ownerId = _vehicle getVariable ["BIS_WL_ownerAsset", "123"];
			if (_ownerId != getPlayerUID player) exitWith { false };
			if (_person in _vehicle) exitWith { false };
			true;
		};

		private _ownedVehicleVar = format ["BIS_WL_ownedVehicles_%1", getPlayerUID player];
		private _ownedVehicles = missionNamespace getVariable [_ownedVehicleVar, []];
		{
			private _vehicle = _x;
			private _assignedDriver = assignedDriver _vehicle;
			if ([_vehicle, _assignedDriver] call _canMoveIn) then {
				_assignedDriver moveInDriver _vehicle;
				playSoundUI ["AddItemOK"];
			};

			private _assignedGunner = assignedGunner _vehicle;
			if ([_vehicle, _assignedGunner] call _canMoveIn) then {
				_assignedGunner moveInGunner _vehicle;
				playSoundUI ["AddItemOK"];
			};

			private _assignedCommander = assignedCommander _vehicle;
			if ([_vehicle, _assignedCommander] call _canMoveIn) then {
				_assignedCommander moveInCommander _vehicle;
				playSoundUI ["AddItemOK"];
			};

			private _assignedCargo = assignedCargo _vehicle;
			{
				if ([_vehicle, _x] call _canMoveIn) then {
					_x moveInCargo _vehicle;
					playSoundUI ["AddItemOK"];
				};
			} forEach _assignedCargo;
		} forEach _ownedVehicles;
	};
}];

#if __GAME_BUILD__ > 153351
(group player) addEventHandler ["LeaderChanged", {
	params ["_group", "_newLeader"];
	if (_newLeader != player) then {
		{
			_x disableAI "COMMAND";
		} forEach (units _group);
	} else {
		{
			_x enableAI "COMMAND";
		} forEach (units _group);
	};
}];
#endif