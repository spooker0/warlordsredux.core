#include "includes.inc"
params ["_orderedClass", "_cost", "_offset"];

private _class = WL_ASSET(_orderedClass, "spawn", _orderedClass);

private _camperWarningBypass = {
	if (_cost < 5000) exitWith {
		true;
	};

	private _side = BIS_WL_playerSide;

	private _teamSectorsData = WL_SECTORS_DATA(_side);
	private _ownedSectors = _teamSectorsData getOrDefault ["owned", []];

	private _findCurrentOwnedSector = _ownedSectors select {
		player inArea (_x getVariable "objectAreaComplete")
	};

	if (count _findCurrentOwnedSector == 0) exitWith {
		true;
	};

	private _sector = _findCurrentOwnedSector # 0;
	private _sectorMarker = _sector getVariable [format ["WL2_MapMarker_%1", _side], "unknown"];
	private _sectorIsCamped = _sectorMarker == "camped";

	private _campResult = if (_sectorIsCamped) then {
		playSoundUI ["AddItemFailed", 1];
		["Camped sector", "Your team has marked this sector as camped! Enemies may be near. Are you sure you would like to spawn your vehicle here?", "Yes", "Cancel"] call WL2_fnc_prompt;
	} else {
		true;
	};
	_campResult
};

if (_class isKindOf "Man") then {
	player setVariable ["BIS_WL_isOrdering", true, [2, clientOwner]];
	_asset = (group player) createUnit [_class, getPosATL player, [], 2, "NONE"];
	_asset setVehiclePosition [getPosATL player, [], 0, "CAN_COLLIDE"];
	_asset setVariable ["BIS_WL_ownerAsset", getPlayerUID player, true];
	[player, "orderAI", _class] remoteExec ["WL2_fnc_handleClientRequest", 2];
	[_asset, player] spawn WL2_fnc_newAssetHandle;
	player setVariable ["BIS_WL_isOrdering", false, [2, clientOwner]];
} else {
	if (visibleMap) then {
		openMap [false, false];
		titleCut ["", "BLACK IN", 0.5];
	};

	if (count _offset != 3) then {
		_offset = [0, 8, 0];
	};

	private _camperWarnDone = call _camperWarningBypass;

	private _deploymentResult = if (_camperWarnDone) then {
		[_class, _orderedClass, _offset, 50, false] call WL2_fnc_deployment;
	} else {
		[false];
	};

	if (_deploymentResult # 0) then {
		player setVariable ["BIS_WL_isOrdering", true, [2, clientOwner]];

		private _pos = _deploymentResult # 1;
		private _direction = _deploymentResult # 3;

		// Griefer check
		private _uid = getPlayerUID player;
		private _nearbyEntities = [_class, _pos, _direction, _uid, []] call WL2_fnc_grieferCheck;

		if (count _nearbyEntities > 0) then {
			private _nearbyObject = _nearbyEntities # 0;
			private _nearbyObjectName = [_nearbyObject] call WL2_fnc_getAssetTypeName;
			private _nearbyObjectPosition = getPosASL _nearbyObject;

			playSound3D ["a3\3den\data\sound\cfgsound\notificationwarning.wss", objNull, false, _nearbyObjectPosition, 5];
			[format ["Too close to another %1!", _nearbyObjectName]] call WL2_fnc_smoothText;
			player setVariable ["BIS_WL_isOrdering", false, [2, clientOwner]];
		} else {
			playSound "assemble_target";
			[player, "orderAsset", "vehicle", _pos, _orderedClass, _direction, true] remoteExec ["WL2_fnc_handleClientRequest", 2];
		};
	} else {
		"Canceled" call WL2_fnc_announcer;
	};
};

uiSleep 0.1;
showCommandingMenu "";