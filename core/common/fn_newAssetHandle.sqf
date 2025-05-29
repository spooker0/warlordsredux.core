#include "..\warlords_constants.inc"

params ["_asset", ["_owner", objNull]];

[_asset] call WL2_fnc_lastHitHandler;

if (isServer) then {
	if !(unitIsUAV _asset) then {
		_asset setSkill (0.2 + random 0.3);
	};

	private _defaultMags = magazinesAllTurrets _asset;
	_asset setVariable ["BIS_WL_defaultMagazines", _defaultMags, true];
	_asset setVariable ["WLM_savedDefaultMags", _defaultMags, true];
};

if (isPlayer _owner) then {
	missionNamespace setVariable ["WL2_afkTimer", serverTime + WL_AFK_TIMER];
};

if (_asset isKindOf "Man") then {
	_asset call APS_fnc_setupProjectiles;

	if (isPlayer _owner) then {
		private _refreshTimerVar = format ["WL2_manpowerRefreshTimers_%1", getPlayerUID player];
		private _manpowerRefreshTimers = missionNamespace getVariable [_refreshTimerVar, []];
		_manpowerRefreshTimers pushBack [serverTime + WL_MANPOWER_REFRESH_COOLDOWN, _asset];
		missionNamespace setVariable [_refreshTimerVar, _manpowerRefreshTimers, true];

		switch (typeof _asset) do {
			case "B_soldier_repair_F";
			case "O_soldier_repair_F": {
				["TaskBuyRepair"] call WLT_fnc_taskComplete;
			};
		};

		call WL2_fnc_teammatesAvailability;

		// Prevent AI shenanigans
		// Allow for now, to prevent the false negative issues.
		// _asset addEventHandler ["GetInMan", {
		// 	params ["_vehicle", "_role", "_unit", "_turret"];
		// 	private _access = [_vehicle, _unit, _role] call WL2_fnc_accessControl;
		// 	if !(_access # 0) then {
		// 		moveOut _unit;
		// 	};
		// }];

		// _asset addEventHandler ["SeatSwitchedMan", {
		// 	params ["_unit1", "_unit2", "_vehicle"];

		// 	if (!isNull _unit1) then {
		// 		private _unit1Role = (assignedVehicleRole _unit1) # 0;
		// 		private _access = [_vehicle, _unit1, _unit1Role] call WL2_fnc_accessControl;
		// 		if !(_access # 0) then {
		// 			moveOut _unit1;
		// 		};
		// 	};

		// 	if (!isNull _unit2) then {
		// 		private _unit2Role = (assignedVehicleRole _unit2) # 0;
		// 		private _access = [_vehicle, _unit2, _unit2Role] call WL2_fnc_accessControl;
		// 		if !(_access # 0) then {
		// 			moveOut _unit2;
		// 		};
		// 	};
		// }];
	};
} else {
	private _side = if (isPlayer _owner) then {
		side group _owner
	} else {
		independent
	};
	private _playerUID = if (isPlayer _owner) then {
		getPlayerUID _owner
	} else {
		"123"
	};

	private _assetActualType = _asset getVariable ["WL2_orderedClass", typeOf _asset];

	[_asset] call APS_fnc_registerVehicle;

	_asset remoteExec ["APS_fnc_setupProjectiles", 0, true];
	[_asset] remoteExec ["WL2_fnc_rearmAction", 0, true];
	[_asset] remoteExec ["WL2_fnc_repairAction", 0, true];
	[_asset] remoteExec ["WL2_fnc_refuelAction", 0, true];
	[_asset] remoteExec ["WL2_fnc_claimAction", 0, true];

	_asset setVariable ["WL2_nextRepair", 0, true];
	_asset setVariable ["BIS_WL_ownerAssetSide", _side, true];
	_asset setVariable ["WL2_massDefault", getMass _asset];

	_var = format ["BIS_WL_ownedVehicles_%1", _playerUID];
	_vehicles = missionNamespace getVariable [_var, []];
	_vehicles pushBack _asset;
	missionNamespace setVariable [_var, _vehicles, [2, clientOwner]];

	[_asset, true] remoteExec ["setVehicleReceiveRemoteTargets", _asset, true];
	[_asset, true] remoteExec ["setVehicleReportRemoteTargets", _asset, true];
	[_asset, true] remoteExec ["setVehicleReportOwnPosition", _asset, true];

	// HMD missile alert system
	_asset addEventHandler ["IncomingMissile", {
		params ["_target", "_ammo", "_vehicle", "_instigator", "_missile"];
		if (isNull _missile) exitWith {};
		_missile setVariable ["WL_launcher", _vehicle];
		private _incomingMissiles = _target getVariable ["WL_incomingMissiles", []];
		private _originalIncomingMissiles = +_incomingMissiles;
		_incomingMissiles pushBackUnique _missile;
		_incomingMissiles = _incomingMissiles select {
			!(isNull _x) && alive _x;
		};
		if (_incomingMissiles isEqualTo _originalIncomingMissiles) exitWith {};
		_target setVariable ["WL_incomingMissiles", _incomingMissiles];
		_target setVariable ["WL_incomingLauncherLastKnown", _vehicle];
	}];

	private _hasScannerMap = missionNamespace getVariable ["WL2_hasScanner", createHashMap];
	if (_hasScannerMap getOrDefault [_assetActualType, false]) then {
		[_asset, false] remoteExec ["WL2_fnc_scannerAction", 0, true];
	};

	private _hasReconOpticsMap = missionNamespace getVariable ["WL2_hasReconOptics", createHashMap];
	if (_hasReconOpticsMap getOrDefault [_assetActualType, false]) then {
		[_asset, false] remoteExec ["WL2_fnc_reconOpticsAction", 0, true];
	};

	private _hasAWACSMap = missionNamespace getVariable ["WL2_hasAWACS", createHashMap];
	if (_hasAWACSMap getOrDefault [_assetActualType, false]) then {
		[_asset, true] remoteExec ["WL2_fnc_scannerAction", 0, true];
	};

	private _loadoutDefaults = profileNamespace getVariable ["WLM_loadoutDefaults", createHashmap];
	if (_assetActualType in _loadoutDefaults) then {
    	private _lastLoadout = _loadoutDefaults getOrDefault [_assetActualType, []];

		private _magTurretsToRemove = [];
		private _turrets = [[-1]] + allTurrets _asset;
		{
			private _turretPath = _x;
			private _magazinesTurret = _asset magazinesTurret _turretPath;
			{
				_magTurretsToRemove pushBack [_x, _turretPath];
			} forEach _magazinesTurret;
		} forEach _turrets;

		[_asset, _magTurretsToRemove, _lastLoadout, true] remoteExec ["WLM_fnc_applyVehicle", 0];
	};

	if !("ToolKit" in (itemCargo _asset)) then {
		_asset addItemCargoGlobal ["ToolKit", 1];
	};

	// handle WLT
	switch (_assetActualType) do {
		case "B_Quadbike_01_F";
		case "O_Quadbike_01_F";
		case "I_Quadbike_01_F": {
			["TaskBuyQuad"] call WLT_fnc_taskComplete;
		};

		case "B_G_Offroad_01_armed_F";
		case "O_G_Offroad_01_armed_F";
		case "I_G_Offroad_01_armed_F": {
			["TaskBuyTechnical"] call WLT_fnc_taskComplete;
		};

		case "B_MBT_01_cannon_F";
		case "B_MBT_01_TUSK_F";
		case "B_MBT_03_cannon_F";
		case "O_MBT_02_cannon_export_F";
		case "O_MBT_02_cannon_F";
		case "O_MBT_04_cannon_F";
		case "O_MBT_04_command_F";
		case "O_MBT_04_nato_F": {
			["TaskBuyMBT"] call WLT_fnc_taskComplete;
		};
	};

	// Vehicle special actions
	switch (_assetActualType) do {
		// Dazzlers
		case "B_T_Truck_03_device_F";
		case "O_Truck_03_device_F": {
			_asset setVariable ["BIS_WL_dazzlerActivated", false, true];
			_asset setVariable ["WL_ewNetActive", false, true];
			_asset setVariable ["WL_ewNetRange", WL_JAMMER_RANGE_OUTER, true];

			[_asset] remoteExec ["WL2_fnc_jammerAction", 0, true];
		};
		case "Land_MobileRadar_01_radar_F": {
			_asset setVariable ["WL_ewNetActive", false, true];
			_asset setVariable ["WL_ewNetRange", WL_JAMMER_RANGE_OUTER * 2, true];

			// reduce height for demolish action
			// private _assetPos = getPosATL _asset;
			// _asset setPosATL [_assetPos # 0, _assetPos # 1, _assetPos # 2 - 8];

			// too hardy otherwise, start off at 10% health
			// _asset setDamage 0.9;
			[_asset] remoteExec ["WL2_fnc_jammerAction", 0, true];
		};

		// Logistics
		case "B_Truck_01_flatbed_F";
		case "O_Truck_01_flatbed_F": {
			[_asset] remoteExec ["WL2_fnc_deployableAddAction", 0, true];
		};
		case "B_T_VTOL_01_vehicle_F": {
			_asset call WL2_fnc_logisticsAddAction;
		};
		case "B_Heli_Transport_01_F";
		case "B_Heli_Transport_01_UP_F";
		case "B_Heli_Transport_03_F";
		case "O_Heli_Light_02_unarmed_F";
		case "O_Heli_Light_02_dynamicLoadout_F";
		case "O_Heli_Transport_04_F";
		case "O_Heli_Transport_02_F";
		case "O_Heli_Transport_02_ATGM_F";
		case "I_Heli_Transport_02_F": {
			[_asset] remoteExec ["WL2_fnc_slingAddAction", 0, true];
		};

		case "Land_Cargo10_blue_F";
		case "Land_Cargo10_red_F": {
			[_asset] remoteExec ["WL2_fnc_setupForwardBaseAction", 0, true];
		};

		case "B_Boat_Armed_01_minigun_F";
		case "B_Boat_Armed_01_autocannon_F";
		case "O_Boat_Armed_01_autocannon_F";
		case "O_Boat_Armed_01_hmg_F": {
			[_asset] spawn WL2_fnc_stabilizeBoatAction;
		};

		case "B_Boat_Transport_02_F";
		case "O_Boat_Transport_02_F": {
			_asset setVariable ["WL2_deployCrates", 1, true];
			[_asset] remoteExec ["WL2_fnc_deployCrateAction", 0, true];
		};

		// case "B_AAA_System_01_F": {
		// 	[_asset] spawn APS_fnc_ciws;
		// };

		// case "I_Heli_light_03_dynamicLoadout_F";
		// case "B_Heli_Attack_01_dynamicLoadout_F";
		// case "O_Heli_Attack_02_dynamicLoadout_F": {
		// 	[_asset] remoteExec ["WL2_fnc_controlGunnerAction", 0, true];
		// };

		// Radars
		case "B_Radar_System_01_F";
		case "O_Radar_System_02_F";
		case "I_E_Radar_System_01_F": {
			_asset setVariable ["radarRotation", false, true];
			[_asset] remoteExec ["WL2_fnc_radarRotateAction", 0, true];

			[_asset] spawn {
				params ["_asset"];
				private _lookAtAngles = [0, 90, 180, 270];
				private _radarIter = 0;
				while {alive _asset} do {
					private _radarRotation = _asset getVariable ["radarRotation", false];
					if (_radarRotation) then {
						private _lookAtPos = _asset getRelPos [100, _lookAtAngles # _radarIter];
						if (local _asset) then {
							_asset lookAt _lookAtPos;
						} else {
							[_asset, _lookAtPos] remoteExec ["lookAt", _asset];
						};
						_radarIter = (_radarIter + 1) % 4;
					};
					sleep 2.4;
				};
			};
		};

		case "RuggedTerminal_01_communications_F": {
			[_asset] remoteExec ["WL2_fnc_remoteControlAction", 0, true];
			_asset animateSource ["Terminal_source", 100, true];
			_asset setObjectTextureGlobal [0, "#(argb,8,8,3)color(0,0,1,1)"];
		};

		// Suicide drones
		case "B_UAV_06_F";
		case "O_UAV_06_F";
		case "I_UAV_06_F": {
			waitUntil {sleep 0.1; !(isNull group _asset)};
			_asset spawn {
				params ["_asset"];
				[
					driver _asset,
					format["<t color='#E5E500' shadow='2'>&#160;%1</t>", "*Arm Drone*"],
					"\a3\ui_f_oldman\data\IGUI\Cfg\holdactions\attack_ca.paa",
					"\a3\ui_f_oldman\data\IGUI\Cfg\holdactions\attack_ca.paa",
					"!(isNull (getConnectedUAVUnit player))",
					"!(isNull (getConnectedUAVUnit player))",
					{
						playSound3D ["a3\sounds_f\sfx\objects\upload_terminal\terminal_antena_close.wss", (getConnectedUAVUnit player), false, getPosASL (getConnectedUAVUnit player), 1, 1, 0];
					},
					{},
					{
						(getConnectedUAVUnit player) addEventHandler ["Killed", {
							params ["_unit", "_killer", "_instigator", "_useEffects"];
							[player, "droneExplode", _unit] remoteExec ["WL2_fnc_handleClientRequest", 2];
						}];
						[
							getConnectedUAVUnit player,
							format["<t color='#f80e1a' shadow='2'>&#160;%1</t>", "*Detonate*"],
							"\a3\ui_f_oldman\data\IGUI\Cfg\holdactions\destroy_ca.paa",
							"\a3\ui_f_oldman\data\IGUI\Cfg\holdactions\destroy_ca.paa",
							"!(isNull (getConnectedUAVUnit player))",
							"!(isNull (getConnectedUAVUnit player))",
							{},
							{},
							{
								[player, "droneExplode", _target] remoteExec ["WL2_fnc_handleClientRequest", 2];
							},
							{},
							[],
							1
						] call BIS_fnc_holdActionAdd;
					},
					{},
					[],
					2
				] call BIS_fnc_holdActionAdd;
			};
		};

		case "C_IDAP_UAV_06_antimine_F": {
			waitUntil {sleep 0.1; !(isNull group _asset)};
		};
	};

	if (_asset getVariable ["apsType", -1] == 3) then {
		[_asset] remoteExec ["WL2_fnc_dazzlerAction", 0, true];
	};

	private _isLightweightMap = missionNamespace getVariable ["WL2_isLightweight", createHashMap];
	private _isLightweight = _isLightweightMap getOrDefault [_assetActualType, false];
	if (_isLightweight) then {
		private _originalMass = getMass _asset;
		[_asset, _originalMass * 0.65] remoteExec ["setMass", 0];
	};

	private _hasESAMMap = missionNamespace getVariable ["WL2_hasESAM", createHashMap];
	private _isESAM = _hasESAMMap getOrDefault [_assetActualType, false];
	if (_isESAM) then {
		[_asset, _side] remoteExec ["DIS_fnc_setupExtendedSam", 0, true];
	};

	private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];
	if (unitIsUAV _asset) then {
		if (_settingsMap getOrDefault ["enableAuto", false] && !isDedicated) then {
			[_asset, false] remoteExec ["setAutonomous", 0];
		} else {
			[_asset, true] remoteExec ["setAutonomous", 0];
		};
		_asset setVariable ["BIS_WL_ownerUavAsset", _playerUID, true];
		[_asset, _owner] spawn WL2_fnc_uavJammer;
		_asset setVariable ["WL_canConnectUav", true];

		private _assetGrp = group _asset;
		private _assetTypeName = [_asset] call WL2_fnc_getAssetTypeName;
		_assetGrp setVariable ["WL2_assetOwner", _owner, true];
		_assetGrp setVariable ["WL2_assetTypeName", _assetTypeName, true];
		[_asset] call WL2_fnc_uavConnectRefresh;
	};

	if (_asset isKindOf "ReammoBox_F") then {
		_asset setVariable ["WL2_accessControl", 2, true];
	} else {
		_asset setVariable ["WL2_accessControl", 4, true];
	};
	[_asset] remoteExec ["WL2_fnc_vehicleLockAction", 0, true];

	if (_asset isKindOf "Plane") then {
		[_asset] remoteExec ["WL2_fnc_catapultAction", 0];
	};

	if (typeOf _asset == "VirtualReammoBox_camonet_F") then {
		private _containerMap = missionNamespace getVariable ["WL2_container", createHashMap];
		private _containerItems = _containerMap getOrDefault [_assetActualType, []];
		{
			private _containerItemType = _x # 0;
			private _containerItemCount = _x # 1;

			private _isBackpack = _containerItemType isKindOf "Bag_Base";
			if (_isBackpack) then {
				_asset addBackpackCargoGlobal [_containerItemType, _containerItemCount];
			} else {
				_asset addItemCargoGlobal [_containerItemType, _containerItemCount];
			};
		} forEach _containerItems;

		[_asset] remoteExec ["WL2_fnc_restockAction", 0, true];
	} else {
		if (_settingsMap getOrDefault ["spawnEmpty", false]) then {
			clearMagazineCargoGlobal _asset;
			clearItemCargoGlobal _asset;
			clearWeaponCargoGlobal _asset;
		};
	};

	if (getNumber (configFile >> "CfgVehicles" >> typeOf _asset >> "transportAmmo") > 0) then {
		[_asset, 0] remoteExec ["setAmmoCargo", 0];
		_amount = 10000;
		if (typeOf _asset == "B_Truck_01_ammo_F" || {typeOf _asset == "O_Truck_03_ammo_F" || {typeOf _asset == "Land_Pod_Heli_Transport_04_ammo_F" || {typeOf _asset == "B_Slingload_01_Ammo_F"}}}) then {
			_amount = ((getNumber (configfile >> "CfgVehicles" >> typeof _asset >> "transportAmmo")) min 30000);
		};
		_asset setVariable ["WLM_ammoCargo", _amount, true];
	};

	if (getNumber (configFile >> "CfgVehicles" >> typeOf _asset >> "transportRepair") > 0) then {
		[_asset, 0] remoteExec ["setRepairCargo", 0];
	};
	if (getNumber (configFile >> "CfgVehicles" >> typeOf _asset >> "transportFuel") > 0) then {
		[_asset, 0] remoteExec ["setFuelCargo", 0];
	};

	private _rearmTime = (missionNamespace getVariable ["WL2_rearmTimers", createHashMap]) getOrDefault [_assetActualType, 600];
	_asset setVariable ["BIS_WL_nextRearm", serverTime + _rearmTime, true];

	private _crewPosition = (fullCrew [_asset, "", true]) select {!("cargo" in _x)};
	private _radarSensor = (listVehicleSensors _asset) select {{"ActiveRadarSensorComponent" in _x} forEach _x};
	private _hasRadar = count _radarSensor > 0 && (count _crewPosition > 1 || unitIsUAV _asset);
	if (_hasRadar) then {
		_asset setVariable ["radarOperation", false, true];
		_asset setVehicleRadar 2;
		[_asset] remoteExec ["WL2_fnc_radarOperateAction", 0, true];

		_asset spawn {
			params ["_asset"];

			while {alive _asset} do {
				private _radarValue = if (_asset getVariable "radarOperation") then {
					1;
				} else {
					2;
				};

				if (local _asset) then {
					_asset setVehicleRadar _radarValue;
				} else {
					[_asset, _radarValue] remoteExec ["setVehicleRadar", _asset];
				};

				sleep 10;
			};
		};
	};

	if (typeOf _asset == "B_APC_Tracked_01_AA_F" || typeOf _asset == "O_APC_Tracked_02_AA_F") then {
		_asset addEventHandler ["Fired", {
			params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_gunner"];
			if (_muzzle == "autocannon_35mm") then {
				private _ammoCount = _unit ammo "autocannon_35mm";
				if (_ammoCount % 5 == 0) then {
					_projectile spawn WL2_fnc_airburst;
				};
			};
		}];
	};

	if (_assetActualType == "B_LSV_01_AT_TV_F") then {
		_asset setTurretLimits [[0], -360, 360, 0, 30];
	};

	private _hasGPSMunitionMap = missionNamespace getVariable ["WL2_hasGPSMunition", createHashMap];
	if (_hasGPSMunitionMap getOrDefault [_assetActualType, false]) then {
		[_asset] remoteExec ["DIS_fnc_setupGPSMunition", 0, true];
	};
	private _hasRemoteBombMap = missionNamespace getVariable ["WL2_hasRemoteBomb", createHashMap];
	if (_hasRemoteBombMap getOrDefault [_assetActualType, false]) then {
		[_asset] remoteExec ["DIS_fnc_setupRemoteMunition", 0, true];
	};

	private _demolishable = missionNamespace getVariable ["WL2_demolishable", createHashMap];
	if (_demolishable getOrDefault [_assetActualType, false]) then {
		_asset setVariable ["WL2_canDemolish", true, true];
	};

	private _parachuteCount = count ((backpackCargo _asset) select {_x == "B_Parachute"});
	if (_parachuteCount > 0) then {
		_asset addEventHandler ["GetOut", {
			params ["_vehicle", "_role", "_unit", "_turret", "_isEject"];

			if (!_isEject) exitWith {};

			[_vehicle, _unit] spawn {
				params ["_vehicle", "_unit"];

				private _height = (getPos _unit) # 2;
				private _distance = _vehicle distance _unit;

				waitUntil {
					sleep 1;
					_height = (getPos _unit) # 2;
					_distance = _vehicle distance _unit;
					_height < 5 || _distance > 10 || !alive _unit || !alive _vehicle;
				};

				if (_height > 5 && alive _unit) then {
					[_unit] spawn WL2_fnc_parachuteSetup;
				};
			};
		}];
	};

	if ("hide_rail" in (animationNames _asset)) then {
		_asset animateSource ["hide_rail", 0];
	};

	if (isPlayer _owner) then {
		private _appearanceDefaults = profileNamespace getVariable ["WLM_appearanceDefaults", createHashmap];
		private _assetAppearanceDefaults = _appearanceDefaults getOrDefault [_assetActualType, createHashmap];
		{
			if (_x == "camo") then {
				[_asset, _y] call WLM_fnc_applyTexture;
			} else {
				[_x, _y, _asset] call WLM_fnc_applyCustomization;
			};
		} forEach _assetAppearanceDefaults;
	};
};

[_asset] remoteExec ["WL2_fnc_removeAction", 0, true];

_asset setVariable ["WL_spawnedAsset", true, true];