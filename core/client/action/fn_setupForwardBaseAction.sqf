#include "includes.inc"
params ["_asset"];

if (isDedicated) exitWith {};
waitUntil {
    uiSleep 1;
    !isNil "BIS_WL_allSectors";
};

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

			private _terminalClass = "RuggedTerminal_01_communications_hub_F";
			private _position = _target modelToWorld [0, 5, 0];
			private _direction = [[0, 0, 1], [1, 0, 0]];

			private _deploymentAction = {
				_target setVariable ["WL2_deploying", true];

				private _deploymentResult = [
					_terminalClass,
					_terminalClass,
					[0, 5, 0],
					50,
					true
				] call WL2_fnc_deployment;

				if !(_deploymentResult # 0) exitWith {
					playSound "AddItemFailed";
					_target setVariable ["WL2_deploying", false];
					false;
				};

				_position =  _deploymentResult # 1;
				private _offset = _deploymentResult # 2;
				_direction = _deploymentResult # 3;
				private _nearbyEntities = [_terminalClass, _position, _direction, "dontcheckuid", [_target]] call WL2_fnc_grieferCheck;

				if (count _nearbyEntities > 0) exitWith {
					private _nearbyObjectName = [_nearbyEntities # 0] call WL2_fnc_getAssetTypeName;
					[format ["Deploying too close to %1!", _nearbyObjectName]] call WL2_fnc_smoothText;
					playSound "AddItemFailed";
					_target setVariable ["WL2_deploying", false];
					false;
				};

				private _eligibility = [_target, player, false, true] call WL2_fnc_setupForwardBaseEligibility;
				if (_eligibility != "") exitWith {
					[_eligibility] call WL2_fnc_smoothText;
					playSound "AddItemFailed";
					_target setVariable ["WL2_deploying", false];
					false;
				};
				true;
			};

			private _exit = false;
			while { WL_ISUP(player) } do {
				private _deployResult = [_target] call _deploymentAction;
				if (_deployResult) then {
					break;
				};
				if (inputAction "navigateMenu" > 0) then {
					_exit = true;
					break;
				};
				uiSleep 1;
			};

			if (_exit) exitWith {};

			[format ["Forward base under construction. %1 seconds remaining.", WL_FOB_SETUP_TIME]] call WL2_fnc_smoothText;

			private _forwardBase = createVehicle [_terminalClass, _position, [], 0, "CAN_COLLIDE"];
			_forwardBase setVectorDirAndUp _direction;
			_forwardBase setPosWorld _position;
			deleteVehicle _target;

			private _side = side group player;
			[_forwardBase, _side, false] remoteExec ["WL2_fnc_setupForwardBaseMp", 0, true];

			_forwardBase setVariable ["WL2_forwardBasePlacer", getPlayerUID player, true];
			_forwardBase setVariable ["WL2_forwardBaseSupplies", 2000, true];
			_forwardBase setVariable ["WL2_services", ["H"], true];

			playSound3D [
				"a3\sounds_f_decade\assets\props\linkterminal_01_node_2_f\link_terminal02_antenna_open.wss",
				_forwardBase, false, getPosASL _forwardBase, 2, 1, 200, 0
			];

			[player, "setupFOB", _forwardBase] remoteExec ["WL2_fnc_handleClientRequest", 2];
		};
	},
	{},
	[],
	2,
	60,
	false
] call BIS_fnc_holdActionAdd;

[_setupActionId, _asset, _drawRestrictionId] spawn {
	params ["_setupActionId", "_asset", "_drawRestrictionId"];

	private _side = BIS_WL_playerSide;

    while { alive _asset } do {
		private _currentForwardBases = missionNamespace getVariable ["WL2_forwardBases", []];
		private _teamForwardBases = _currentForwardBases select {
			_x getVariable ["WL2_forwardBaseOwner", sideUnknown] == _side
		};
		private _inRangeTeamForwardBases = _teamForwardBases select {
			_asset distance2D _x < WL_FOB_RANGE
		};
		private _inRangeTeamFob = if (count _inRangeTeamForwardBases > 0) then {
			true
		} else {
			private _teamSectorsData = WL_SECTORS_DATA(_side);
			private _ownedSectors = _teamSectorsData getOrDefault ["owned", []];
			private _sectorsInRange = _ownedSectors select {
				_asset inArea (_x getVariable "objectAreaComplete")
			};
			count _sectorsInRange > 0
		};

		if (_inRangeTeamFob) then {
			private _setupMessage = [_asset, player, true] call WL2_fnc_setupForwardBaseEligibility;
			_asset setVariable ["WL2_setupActionRestriction", _setupMessage];
		} else {
			private _setupMessage = [_asset, player] call WL2_fnc_setupForwardBaseEligibility;
			_asset setVariable ["WL2_setupActionRestriction", _setupMessage];
		};

        uiSleep 1;
    };

	removeMissionEventHandler ["Draw3D", _drawRestrictionId];
};

[
	_asset,
	"<t color='#00ff00'>Add Supplies</t>",
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
		private _side = BIS_WL_playerSide;
		private _forwardBases = missionNamespace getVariable ["WL2_forwardBases", []];
		_forwardBases = _forwardBases select {
			_target distance2D _x < WL_FOB_RANGE
		} select {
			_x getVariable ["WL2_forwardBaseOwner", sideUnknown] == _side
		};
		if (count _forwardBases > 0) exitWith {
			deleteVehicle _target;

			private _forwardBase = _forwardBases # 0;
			private _forwardBaseSupplies = _forwardBase getVariable ["WL2_forwardBaseSupplies", 0];
			private _newSupplies = _forwardBaseSupplies + 20000;
			_forwardBase setVariable ["WL2_forwardBaseSupplies", _newSupplies, true];
		};

		private _teamSectorsData = WL_SECTORS_DATA(_side);
		private _ownedSectors = _teamSectorsData getOrDefault ["owned", []];
		private _sectorsInRange = _ownedSectors select {
			_target inArea (_x getVariable "objectAreaComplete")
		};
		if (count _sectorsInRange > 0) exitWith {
			deleteVehicle _target;

			private _sector = _sectorsInRange # 0;
			private _currentDefenders = _sector getVariable ["WL2_defenders", 0];
			private _maxDefenders = _sector getVariable ["WL2_maxDefenders", 0];
			_sector setVariable ["WL2_defenders", (_currentDefenders + WL_DEFENDER_ADD) min _maxDefenders, true];
			_sector setVariable ["WL2_strongholdAllowTime", 0, true];

			private _sectorStronghold = _sector getVariable ["WL_stronghold", objNull];
			if (!isNull _sectorStronghold) then {
				private _strongholdMaxHealth = _sectorStronghold getVariable ["WL2_demolitionMaxHealth", 0];
				_strongholdMaxHealth = (_strongholdMaxHealth + 8) min 24;
				_sectorStronghold setVariable ["WL2_demolitionMaxHealth", _strongholdMaxHealth, true];
				_sectorStronghold setVariable ["WL2_demolitionHealth", _strongholdMaxHealth, true];
			};

			[_sector, -1] remoteExec ["WL2_fnc_warnSectorDefenders", 2];
		};

		["No friendly forward base or sector in range!"] call WL2_fnc_smoothText;
		playSoundUI ["AddItemFailed"];
	},
	{},
	[],
	1,
	60,
	false
] call BIS_fnc_holdActionAdd;