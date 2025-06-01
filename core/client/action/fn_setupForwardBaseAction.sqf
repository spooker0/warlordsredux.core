#include "..\..\warlords_constants.inc"

params ["_asset"];

if (isDedicated) exitWith {};

private _drawRestrictionId = addMissionEventHandler ["Draw3D", {
	private _assetNetId = _thisArgs # 0;
	private _asset = objectFromNetId _assetNetId;
	if (!alive _asset) exitWith {};
	if (cameraOn distance _asset > 50) exitWith {};
	if (cursorObject != _asset) exitWith {};
	private _restriction = _asset getVariable ["WL2_setupActionRestriction", ""];
	if (_restriction == "") exitWith {};

	private _position = ASLtoAGL (getPosASL _asset);
	_position set [2, _position # 2 + 1.5];
	drawIcon3D [
        "\a3\ui_f\data\IGUI\Cfg\Actions\Obsolete\ui_action_cancel_ca.paa",
        [1, 0.2, 0.2, 1],
        _asset modelToWorld [0, 0, 0],
        1.0,
		1.0,
        0,
        _restriction,
        true,
        0.045,
        "TahomaB",
        "center",
        false,
		0,
		0.01
    ];
}, [netId _asset]];

private _setupActionId = [
	_asset,
	"<t color='#00ff00'>Setup Forward Base</t>",
	"\A3\Ui_f\data\IGUI\Cfg\HoldActions\holdAction_requestLeadership_ca.paa",
	"\A3\Ui_f\data\IGUI\Cfg\HoldActions\holdAction_requestLeadership_ca.paa",
	"([_target, _this] call WL2_fnc_setupForwardBaseEligibility) == ''",
	"([_target, _this] call WL2_fnc_setupForwardBaseEligibility) == ''",
	{},
	{
		params ["_target", "_caller", "_actionId", "_arguments", "_frame", "_maxFrame"];
		if (_frame % 2 != 0) exitWith {};

		private _impactSounds = [
			"a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_hard_01.wss",
			"a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_hard_02.wss",
			"a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_hard_03.wss",
			"a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_hard_04.wss",
			"a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_soft_01.wss",
			"a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_soft_02.wss",
			"a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_soft_03.wss",
			"a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_metal_01.wss",
			"a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_metal_02.wss",
			"a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_metal_03.wss",
			"a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_metal_04.wss",
			"a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_plastic_01.wss",
			"a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_plastic_02.wss",
			"a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_plastic_03.wss",
			"a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_plastic_04.wss"
		];
		playSound3D [selectRandom _impactSounds, player, false, getPosASL player, 2, 0.5, 200, 0];
	},
	{
		params ["_target", "_caller"];
		[_target] spawn {
			params ["_target"];
			_target setVariable ["WL2_deploying", true];

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
				_target setVariable ["WL2_deploying", false];
			};

			private _position =  _deploymentResult # 1;
			private _offset = _deploymentResult # 2;
			private _direction = _deploymentResult # 3;
			private _nearbyEntities = [_terminalClass, _position, _direction, "dontcheckuid", [_target]] call WL2_fnc_grieferCheck;

			if (count _nearbyEntities > 0) exitWith {
				private _nearbyObjectName = [_nearbyEntities # 0] call WL2_fnc_getAssetTypeName;
				systemChat format ["Deploying too close to %1!", _nearbyObjectName];
				playSound "AddItemFailed";
				_target setVariable ["WL2_deploying", false];
			};

			systemChat format ["Forward base under construction. %1 seconds remaining.", WL_FOB_SETUP_TIME];
			private _endTime = serverTime + WL_FOB_SETUP_TIME;

			private _forwardBase = createVehicle [_terminalClass, _position, [], 0, "CAN_COLLIDE"];
			_forwardBase setVectorDirAndUp _direction;
			_forwardBase setPosWorld _position;
			deleteVehicle _target;

			private _side = side group player;
			[_forwardBase, serverTime, _endTime, _side, false] remoteExec ["WL2_fnc_setupForwardBaseMp", 0, true];

			playSound3D [
				"a3\sounds_f_decade\assets\props\linkterminal_01_node_2_f\link_terminal02_antenna_open.wss",
				_forwardBase, false, getPosASL _forwardBase, 2, 1, 200, 0
			];
		};
	},
	{},
	[],
	5,
	6,
	false
] call BIS_fnc_holdActionAdd;

[_setupActionId, _asset, _drawRestrictionId] spawn {
	params ["_setupActionId", "_asset", "_drawRestrictionId"];

    while { alive _asset } do {
		private _currentForwardBases = missionNamespace getVariable ["WL2_forwardBases", []];
		private _teamForwardBases = _currentForwardBases select {
			_x getVariable ["WL2_forwardBaseOwner", sideUnknown] == side group player
		};
		private _inRangeTeamForwardBases = _teamForwardBases select {
			_asset distance2D _x < WL_FOB_RANGE
		};
		if (count _inRangeTeamForwardBases > 0) then {
			private _setupMessage = [_asset, player, true] call WL2_fnc_setupForwardBaseEligibility;
			_asset setVariable ["WL2_setupActionRestriction", _setupMessage];
		} else {
			private _setupMessage = [_asset, player] call WL2_fnc_setupForwardBaseEligibility;
			_asset setVariable ["WL2_setupActionRestriction", _setupMessage];
		};

        sleep 1;
    };

	removeMissionEventHandler ["Draw3D", _drawRestrictionId];
};

[
	_asset,
	"<t color='#00ff00'>Add Supplies to Base</t>",
	"\A3\Ui_f\data\IGUI\Cfg\HoldActions\holdAction_loadDevice_ca.paa",
	"\A3\Ui_f\data\IGUI\Cfg\HoldActions\holdAction_loadDevice_ca.paa",
	"([_target, _this, true] call WL2_fnc_setupForwardBaseEligibility) == ''",
	"([_target, _this, true] call WL2_fnc_setupForwardBaseEligibility) == ''",
	{},
	{
		params ["_target", "_caller", "_actionId", "_arguments", "_frame", "_maxFrame"];
		if (_frame % 2 != 0) exitWith {};
		private _impactSounds = [
			"a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_hard_01.wss",
			"a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_hard_02.wss",
			"a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_hard_03.wss",
			"a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_hard_04.wss",
			"a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_soft_01.wss",
			"a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_soft_02.wss",
			"a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_soft_03.wss",
			"a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_metal_01.wss",
			"a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_metal_02.wss",
			"a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_metal_03.wss",
			"a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_metal_04.wss",
			"a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_plastic_01.wss",
			"a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_plastic_02.wss",
			"a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_plastic_03.wss",
			"a3\sounds_f_enoch\assets\arsenal\ugv_02\probingweapon_01\ugv_lance_impact_plastic_04.wss"
		];
		playSound3D [selectRandom _impactSounds, player, false, getPosASL player, 2, 0.5, 200, 0];
	},
	{
		params ["_target", "_caller"];
		private _forwardBases = missionNamespace getVariable ["WL2_forwardBases", []];
		_forwardBases = _forwardBases select {
			_target distance2D _x < WL_FOB_RANGE &&
			_x getVariable ["WL2_forwardBaseOwner", sideUnknown] == side group player
		};
		if (count _forwardBases == 0) exitWith {
			systemChat "No friendly forward base in range!";
			playSound "AddItemFailed";
		};

		private _forwardBase = _forwardBases # 0;
		if (_forwardBase getVariable ["WL2_forwardBaseTime", 0] > serverTime) exitWith {
			systemChat "Forward base is still under construction!";
			playSound "AddItemFailed";
		};

		deleteVehicle _target;
		private _forwardBaseSupplies = _forwardBase getVariable ["WL2_forwardBaseSupplies", 0];
		private _newSupplies = _forwardBaseSupplies + 20000;
		_forwardBase setVariable ["WL2_forwardBaseSupplies", _newSupplies, true];
	},
	{},
	[],
	2,
	6,
	false
] call BIS_fnc_holdActionAdd;