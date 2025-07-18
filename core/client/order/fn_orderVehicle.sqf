#include "includes.inc"
params ["_orderedClass", "_cost", "_offset"];

player setVariable ["BIS_WL_isOrdering", true, [2, clientOwner]];

private _class = WL_ASSET(_orderedClass, "spawn", _orderedClass);

if (_class isKindOf "Man") then {
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

	private _deploymentResult = [_class, _orderedClass, _offset, 50, false] call WL2_fnc_deployment;

	if (_deploymentResult # 0) then {
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
			systemChat format ["Too close to another %1!", _nearbyObjectName];
			player setVariable ["BIS_WL_isOrdering", false, [2, clientOwner]];
		} else {
			playSound "assemble_target";
			private _isExactPosition = false;

			private _isDemolishable = WL_ASSET(_orderedClass, "demolishable", 0) > 0;
			if (_isDemolishable) then {
				_isExactPosition = true;
			};

			private _sectors = BIS_WL_allSectors select {
				_pos inArea (_x getVariable "objectAreaComplete")
			};
			if (count _sectors > 0) then {
				private _sector = _sectors # 0;
				private _sectorStronghold = _sector getVariable ["WL_stronghold", objNull];
				private _strongholdRadius = _sectorStronghold getVariable ["WL_strongholdRadius", 0];
				private _assetInStronghold = _pos distance2D _sectorStronghold < _strongholdRadius;
				if (_assetInStronghold) then {
					_isExactPosition = true;
				};
			};

			[player, "orderAsset", "vehicle", _pos, _orderedClass, _direction, _isExactPosition] remoteExec ["WL2_fnc_handleClientRequest", 2];
		};
	} else {
		"Canceled" call WL2_fnc_announcer;
		[toUpper localize "STR_A3_WL_deploy_canceled"] spawn WL2_fnc_smoothText;
		player setVariable ["BIS_WL_isOrdering", false, [2, clientOwner]];
	};
};

sleep 0.1;
showCommandingMenu "";