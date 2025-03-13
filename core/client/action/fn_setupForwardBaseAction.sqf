#include "..\..\warlords_constants.inc"

private _setupActionId = player addAction [
	"<t color='#00ff00'>Setup Forward Base</t>",
	{
		private _forwardBaseSupplies = cursorObject;
		if (isNull _forwardBaseSupplies) exitWith {};
		if (typeof _forwardBaseSupplies != "VirtualReammoBox_camonet_F") exitWith {};
		if (player distance _forwardBaseSupplies > WL_MAINTENANCE_RADIUS) exitWith {};

		private _eligibility = [player, player, false] call WL2_fnc_setupForwardBaseEligibility;
		if (_eligibility # 1 != "") exitWith {
			playSoundUI ["AddItemFailed"];
			systemChat (_eligibility # 1);
		};

		[_forwardBaseSupplies] spawn {
			params ["_forwardBaseSupplies"];

			private _terminalClass = "RuggedTerminal_01_communications_hub_F";
			private _deploymentResult = [
				_terminalClass,
				_terminalClass,
				[0, 5, 0],
				20,
				true
			] call WL2_fnc_deployment;

			if !(_deploymentResult # 0) exitWith {
				playSound "AddItemFailed";
			};

			private _position =  _deploymentResult # 1;
			private _offset = _deploymentResult # 2;
			private _direction = _deploymentResult # 3;
			private _nearbyEntities = [_terminalClass, _position, _direction, "dontcheckuid", [_forwardBaseSupplies]] call WL2_fnc_grieferCheck;

			if (count _nearbyEntities > 0) exitWith {
				private _nearbyObjectName = [_nearbyEntities # 0] call WL2_fnc_getAssetTypeName;
				systemChat format ["Deploying too close to %1!", _nearbyObjectName];
				playSound "AddItemFailed";
			};

			systemChat format ["Forward base under construction. %1 seconds remaining.", WL_FOB_SETUP_TIME];
			private _endTime = serverTime + WL_FOB_SETUP_TIME;

			private _forwardBase = createVehicle [_terminalClass, _position, [], 0, "CAN_COLLIDE"];
			_forwardBase setVectorDirAndUp _direction;
			_forwardBase setPosWorld _position;
			deleteVehicle _forwardBaseSupplies;

			private _side = side group player;
			[_forwardBase, serverTime, _endTime, _side, false] remoteExec ["WL2_fnc_setupForwardBaseMp", 0, true];
		};
	},
	[],
	6,
	true,
	true,
	"",
	"([_target, _this, false] call WL2_fnc_setupForwardBaseEligibility) # 0",
	WL_MAINTENANCE_RADIUS,
	false
];

private _moneySign = [BIS_WL_playerSide] call WL2_fnc_getMoneySign;
private _upgradeActionId = player addAction [
    format ["<t color='#00ff00'>Upgrade Forward Base (Cost: %1%2)</t>", _moneySign, WL_FOB_UPGRADE_COST],
    {
		private _eligibility = [player, player, true] call WL2_fnc_setupForwardBaseEligibility;
		if (_eligibility # 1 != "") exitWith {
			playSoundUI ["AddItemFailed"];
			systemChat (_eligibility # 1);
		};

        private _forwardBase = cursorObject;
        systemChat format ["Forward base upgrading. %1 seconds remaining.", WL_FOB_UPGRADE_TIME];
        private _endTime = serverTime + WL_FOB_UPGRADE_TIME;
        [_forwardBase, serverTime, _endTime, player, true] remoteExec ["WL2_fnc_setupForwardBaseMp", 0, true];
        [player, "upgradeFOB"] remoteExec ["WL2_fnc_handleClientRequest", 2];
    },
    [],
    6,
    true,
    true,
    "",
    "([_target, _this, true] call WL2_fnc_setupForwardBaseEligibility) # 0",
    WL_MAINTENANCE_RADIUS,
    false
];

[_setupActionId, _upgradeActionId] spawn {
	params ["_setupActionId", "_upgradeActionId"];
	private _moneySign = [BIS_WL_playerSide] call WL2_fnc_getMoneySign;
    while { alive player } do {
		private _setupMessage = [player, player, false] call WL2_fnc_setupForwardBaseEligibility;
		if (_setupMessage # 0) then {
			private _message = _setupMessage # 1;
			if (_message != "") then {
				player setUserActionText [
					_setupActionId,
					"<t color='#ff0000'>Can't Setup Forward Base</t>"
				];
			} else {
				player setUserActionText [
					_setupActionId,
					"<t color='#00ff00'>Setup Forward Base</t>"
				];
			};
		};

		private _upgradeMessage = [player, player, true] call WL2_fnc_setupForwardBaseEligibility;
		if (_upgradeMessage # 0) then {
			private _message = _upgradeMessage # 1;
			if (_message != "") then {
				player setUserActionText [
					_upgradeActionId,
					"<t color='#ff0000'>Can't Upgrade Forward Base</t>"
				];
			} else {
				player setUserActionText [
					_upgradeActionId,
					format ["<t color='#00ff00'>Upgrade Forward Base (Cost: %1%2)</t>", _moneySign, WL_FOB_UPGRADE_COST]
				];
			};
		};

        sleep 1;
    };
};